import { UserRole } from "@prisma/client";
import { createSuperAdminClient, prisma } from "../src/lib/db";

async function main() {
  const email = process.env.SUPER_ADMIN_EMAIL;
  const passwordHash = process.env.SUPER_ADMIN_PASSWORD_HASH;

  if (!email || !passwordHash) {
    throw new Error(
      "SUPER_ADMIN_EMAIL and SUPER_ADMIN_PASSWORD_HASH are required; provide a bcrypt hash in phase 1",
    );
  }

  const superAdmin = await createSuperAdminClient((transaction) =>
    transaction.user.upsert({
      where: { email },
      update: { passwordHash, role: UserRole.SUPER_ADMIN, tenantId: null },
      create: {
        email,
        passwordHash,
        role: UserRole.SUPER_ADMIN,
        tenantId: null,
      },
    }),
  );

  console.info(`Seeded Super Admin ${superAdmin.id}`);
}

main()
  .catch((error: unknown) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });