export function formatMobileMoneyPhone(phone: string) {
  return phone.replace(/[^0-9]/g, "");
}

export function validateMMAmount(amount: number) {
  return amount > 0;
}
