import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Maeen Software Ai",
  description: "منصة خدمة عملاء واتساب متعددة العملاء بالذكاء الاصطناعي",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}