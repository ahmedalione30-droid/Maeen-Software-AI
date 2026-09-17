CREATE EXTENSION IF NOT EXISTS "vector";

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'SUPER_ADMIN');

-- CreateEnum
CREATE TYPE "ConversationStatus" AS ENUM ('open', 'closed', 'escalated');

-- CreateEnum
CREATE TYPE "MessageDirection" AS ENUM ('inbound', 'outbound');

-- CreateTable
CREATE TABLE "tenants" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "plan" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "tenant_id" UUID,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_accounts" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "waba_id" TEXT NOT NULL,
    "phone_number_id" TEXT NOT NULL,
    "display_phone" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "verify_token" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "whatsapp_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contacts" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "phone_number" TEXT NOT NULL,
    "name" TEXT,
    "opted_in" BOOLEAN NOT NULL DEFAULT false,
    "tags" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "contact_id" UUID NOT NULL,
    "status" "ConversationStatus" NOT NULL,
    "last_message_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "conversation_id" UUID NOT NULL,
    "direction" "MessageDirection" NOT NULL,
    "content" TEXT NOT NULL,
    "ai_generated" BOOLEAN NOT NULL DEFAULT false,
    "whatsapp_msg_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knowledge_bases" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "knowledge_bases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knowledge_chunks" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "knowledge_base_id" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "embedding" vector(1536) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "knowledge_chunks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscriptions" (
    "id" UUID NOT NULL,
    "tenant_id" UUID NOT NULL,
    "stripe_customer_id" TEXT,
    "stripe_subscription_id" TEXT,
    "status" TEXT NOT NULL,
    "current_period_end" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "tenant_id" UUID,
    "user_id" UUID,
    "action" TEXT NOT NULL,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "tenants_slug_key" ON "tenants"("slug");
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE UNIQUE INDEX "whatsapp_accounts_phone_number_id_key" ON "whatsapp_accounts"("phone_number_id");
CREATE UNIQUE INDEX "contacts_tenant_id_phone_number_key" ON "contacts"("tenant_id", "phone_number");
CREATE INDEX "users_tenant_id_idx" ON "users"("tenant_id");
CREATE INDEX "whatsapp_accounts_tenant_id_idx" ON "whatsapp_accounts"("tenant_id");
CREATE INDEX "contacts_tenant_id_idx" ON "contacts"("tenant_id");
CREATE INDEX "conversations_tenant_id_idx" ON "conversations"("tenant_id");
CREATE INDEX "conversations_tenant_id_last_message_at_idx" ON "conversations"("tenant_id", "last_message_at");
CREATE INDEX "messages_tenant_id_idx" ON "messages"("tenant_id");
CREATE INDEX "messages_tenant_id_conversation_id_created_at_idx" ON "messages"("tenant_id", "conversation_id", "created_at");
CREATE INDEX "knowledge_bases_tenant_id_idx" ON "knowledge_bases"("tenant_id");
CREATE INDEX "knowledge_chunks_tenant_id_idx" ON "knowledge_chunks"("tenant_id");
CREATE INDEX "knowledge_chunks_tenant_id_knowledge_base_id_idx" ON "knowledge_chunks"("tenant_id", "knowledge_base_id");
CREATE INDEX "subscriptions_tenant_id_idx" ON "subscriptions"("tenant_id");
CREATE INDEX "audit_logs_tenant_id_idx" ON "audit_logs"("tenant_id");
CREATE INDEX "audit_logs_tenant_id_created_at_idx" ON "audit_logs"("tenant_id", "created_at");

-- CreateForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "whatsapp_accounts" ADD CONSTRAINT "whatsapp_accounts_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "contacts" ADD CONSTRAINT "contacts_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contacts"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "messages_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "knowledge_bases" ADD CONSTRAINT "knowledge_bases_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "knowledge_chunks" ADD CONSTRAINT "knowledge_chunks_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "knowledge_chunks" ADD CONSTRAINT "knowledge_chunks_knowledge_base_id_fkey" FOREIGN KEY ("knowledge_base_id") REFERENCES "knowledge_bases"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Super Admin is the only user allowed to omit tenant_id.
ALTER TABLE "users"
  ADD CONSTRAINT "users_tenant_role_check"
  CHECK (
    ("role" = 'SUPER_ADMIN' AND "tenant_id" IS NULL)
    OR ("role" <> 'SUPER_ADMIN' AND "tenant_id" IS NOT NULL)
  );

-- Defense in depth: tenant-scoped tables are invisible without a tenant context.
DO $$
DECLARE
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[
    'users',
    'whatsapp_accounts',
    'contacts',
    'conversations',
    'messages',
    'knowledge_bases',
    'knowledge_chunks',
    'subscriptions'
  ]
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_name);
    EXECUTE format(
      'CREATE POLICY %I_tenant_isolation ON %I
       USING (
         current_setting(''app.is_super_admin'', true) = ''true''
         OR tenant_id = NULLIF(current_setting(''app.tenant_id'', true), '''')::uuid
       )
       WITH CHECK (
         current_setting(''app.is_super_admin'', true) = ''true''
         OR tenant_id = NULLIF(current_setting(''app.tenant_id'', true), '''')::uuid
       )',
      table_name,
      table_name
    );
  END LOOP;
END $$;

ALTER TABLE "audit_logs" ENABLE ROW LEVEL SECURITY;
CREATE POLICY audit_logs_tenant_isolation ON "audit_logs"
  USING (
    (tenant_id IS NOT NULL AND tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid)
    OR (tenant_id IS NULL AND current_setting('app.is_super_admin', true) = 'true')
  )
  WITH CHECK (
    (tenant_id IS NOT NULL AND tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid)
    OR (tenant_id IS NULL AND current_setting('app.is_super_admin', true) = 'true')
  );