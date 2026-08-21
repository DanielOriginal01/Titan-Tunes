export async function createMobileMoneyPayment(payload: { amount: number; phone: string; currency: string }) {
  return { status: "pending", ...payload };
}
