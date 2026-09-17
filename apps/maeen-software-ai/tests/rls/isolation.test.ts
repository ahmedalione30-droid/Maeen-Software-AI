import { randomUUID } from "node:crypto";
import assert from "node:assert/strict";
import { after, before, describe, it } from "node:test";
import { Client } from "pg";

const databaseUrl = process.env.RLS_TEST_DATABASE_URL;
if (databaseUrl) {
  const hostname = new URL(databaseUrl).hostname;
  if (!["localhost", "127.0.0.1", "::1"].includes(hostname)) {
    throw new Error(
      "RLS_TEST_DATABASE_URL must point to a local PostgreSQL instance",
    );
  }
}
const shouldRun = Boolean(databaseUrl);

describe("PostgreSQL tenant isolation", { skip: !shouldRun }, () => {
  let client: Client;
  let tenantA: string;
  let tenantB: string;

  before(async () => {
    client = new Client({ connectionString: databaseUrl });
    await client.connect();
    tenantA = randomUUID();
    tenantB = randomUUID();

    await client.query("BEGIN");
    await client.query(
      "SELECT set_config('app.is_super_admin', 'true', true)",
    );
    await client.query(
      "INSERT INTO tenants (id, name, slug, plan, status, updated_at) VALUES ($1, $2, $3, $4, $5, NOW()), ($6, $7, $8, $9, $10, NOW())",
      [
        tenantA,
        "Tenant A",
        `tenant-a-${tenantA}`,
        "trial",
        "active",
        tenantB,
        "Tenant B",
        `tenant-b-${tenantB}`,
        "trial",
        "active",
      ],
    );
    await client.query(
      "INSERT INTO contacts (id, tenant_id, phone_number, opted_in, metadata, updated_at) VALUES ($1, $2, $3, true, '{}', NOW()), ($4, $5, $6, true, '{}', NOW())",
      [randomUUID(), tenantA, "+967700000001", randomUUID(), tenantB, "+967700000002"],
    );
    await client.query("COMMIT");
  });

  after(async () => {
    await client.query("DELETE FROM tenants WHERE id IN ($1, $2)", [tenantA, tenantB]);
    await client.end();
  });

  it("does not expose Tenant B rows from a Tenant A transaction", async () => {
    await client.query("BEGIN");
    await client.query("SELECT set_config('app.tenant_id', $1, true)", [tenantA]);
    await client.query(
      "SELECT set_config('app.is_super_admin', 'false', true)",
    );
    const result = await client.query(
      "SELECT tenant_id, phone_number FROM contacts ORDER BY phone_number",
    );
    await client.query("ROLLBACK");

    assert.equal(result.rows.length, 1);
    assert.deepEqual(result.rows[0], {
      tenant_id: tenantA,
      phone_number: "+967700000001",
    });
  });

  it("rejects a cross-tenant insert", async () => {
    await client.query("BEGIN");
    await client.query("SELECT set_config('app.tenant_id', $1, true)", [tenantA]);
    await client.query(
      "SELECT set_config('app.is_super_admin', 'false', true)",
    );

    await assert.rejects(
      client.query(
        "INSERT INTO contacts (id, tenant_id, phone_number, opted_in, metadata, updated_at) VALUES ($1, $2, $3, true, '{}', NOW())",
        [randomUUID(), tenantB, "+967700000003"],
      ),
      (error: unknown) =>
        typeof error === "object" &&
        error !== null &&
        "code" in error &&
        error.code === "42501",
    );

    await client.query("ROLLBACK");
  });
});