export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-[#E5E7EB] px-6 text-[#0B0B0B]">
      <section className="w-full max-w-lg rounded-3xl bg-white p-10 shadow-sm">
        <div className="mb-8 grid size-14 place-items-center rounded-2xl bg-[#0B0B0B] text-xl font-bold text-white">
          i
        </div>
        <p className="mb-2 text-sm font-semibold tracking-[0.18em] text-[#6B7280]">
          IMOVIA
        </p>
        <h1 className="text-3xl font-semibold tracking-tight">Back-office</h1>
        <p className="mt-3 text-sm leading-6 text-[#6B7280]">
          Base Next.js recréée. Les écrans de gestion seront construits après
          validation des contrats et permissions de l’API.
        </p>
      </section>
    </main>
  );
}
