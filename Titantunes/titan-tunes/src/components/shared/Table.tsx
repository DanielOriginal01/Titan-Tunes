type TableProps = {
  headers: string[];
  rows: React.ReactNode[][];
};

export default function Table({ headers, rows }: TableProps) {
  return (
    <div className="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <table className="min-w-full border-separate border-spacing-0 text-sm text-slate-700">
        <thead className="bg-slate-50 text-left text-xs uppercase tracking-[0.2em] text-slate-500">
          <tr>
            {headers.map((header) => (
              <th key={header} className="px-6 py-4">
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, index) => (
            <tr key={index} className="border-t border-slate-200 hover:bg-slate-50">
              {row.map((cell, cellIndex) => (
                <td key={cellIndex} className="px-6 py-4">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
