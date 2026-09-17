import { PrismaClient, type Prisma } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma?: PrismaClient;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

export type TenantTransaction = Prisma.TransactionClient;

/**
 * All tenant-scoped application queries must use this helper.
 * SET LOCAL is transaction-scoped and cannot leak a tenant context to another request.
 */
export async function createTenantClient<T>(
  tenantId: string,
  callback: (transaction: TenantTransaction) => Promise<T>,
): Promise<T> {
  if (!tenantId) {
    throw new Error("tenantId is required for tenant-scoped database access");
  }

  return prisma.$transaction(async (transaction) => {
    await transaction.$executeRaw`SELECT set_config('app.tenant_id', ${tenantId}, true)`;
    await transaction.$executeRaw`SELECT set_config('app.is_super_admin', 'false', true)`;
    return callback(transaction);
  });
}

export async function createSuperAdminClient<T>(
  callback: (transaction: TenantTransaction) => Promise<T>,
): Promise<T> {
  return prisma.$transaction(async (transaction) => {
    await transaction.$executeRaw`SELECT set_config('app.is_super_admin', 'true', true)`;
    return callback(transaction);
  });
}