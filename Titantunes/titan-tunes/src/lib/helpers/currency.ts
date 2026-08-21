export function formatCurrency(amount: number, currency = "XAF") {
  return new Intl.NumberFormat("fr-FR", { style: "currency", currency }).format(amount);
}
