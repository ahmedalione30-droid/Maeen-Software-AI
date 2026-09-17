export default function HomePage() {
  return (
    <main className="min-h-screen bg-slate-950 px-6 py-24 text-slate-100">
      <div className="mx-auto max-w-4xl">
        <p className="mb-4 text-sm font-medium text-cyan-300">Maeen Software Ai</p>
        <h1 className="text-4xl font-bold tracking-tight sm:text-6xl">
          منصة خدمة عملاء واتساب متعددة العملاء
        </h1>
        <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-300">
          الأساس التقني للمنصة قيد الإعداد. تم تجهيز بنية Next.js وPostgreSQL
          وPrisma مع عزل المستأجرين على مستوى التطبيق وقاعدة البيانات.
        </p>
      </div>
    </main>
  );
}