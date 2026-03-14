module ApplicationHelper
  def dashboard_sidebar_icon(name)
    icons = {
      dashboard: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 13h8V3H3v10Zm10 8h8V3h-8v18ZM3 21h8v-6H3v6Z" fill="currentColor"/></svg>',
      users: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M16 11c1.66 0 2.99-1.57 2.99-3.5S17.66 4 16 4s-3 1.57-3 3.5S14.34 11 16 11ZM8 11c1.66 0 2.99-1.57 2.99-3.5S9.66 4 8 4 5 5.57 5 7.5 6.34 11 8 11Zm0 2c-2.33 0-7 1.17-7 3.5V20h14v-3.5C15 14.17 10.33 13 8 13Zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.96 1.97 3.45V20h6v-3.5c0-2.33-4.67-3.5-7-3.5Z" fill="currentColor"/></svg>',
      listings: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v2H4V5Zm0 6h16v2H4v-2Zm0 6h10v2H4v-2Zm12-1 4 3v-8l-4 3V5h-2v14h2v-3Z" fill="currentColor"/></svg>',
      messages: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 4h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H8l-4 4V6a2 2 0 0 1 2-2Zm2 4v2h12V8H6Zm0 4v2h8v-2H6Z" fill="currentColor"/></svg>',
      leads: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M16 11c1.66 0 3-1.79 3-4s-1.34-4-3-4-3 1.79-3 4 1.34 4 3 4Zm-8 0c1.66 0 3-1.79 3-4S9.66 3 8 3 5 4.79 5 7s1.34 4 3 4Zm0 2c-2.67 0-8 1.34-8 4v2h10v-2c0-1.16.43-2.2 1.15-3.08C10.07 13.34 8.9 13 8 13Zm8 0c-.9 0-2.07.34-3.15.92A4.97 4.97 0 0 1 14 17v2h10v-2c0-2.66-5.33-4-8-4Z" fill="currentColor"/></svg>',
      sales: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 9.2h3V19H5V9.2Zm5.5-4.1h3V19h-3V5.1ZM16 12h3v7h-3v-7ZM3 21h18v-2H3v2Z" fill="currentColor"/></svg>',
      analytics: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a10 10 0 1 0 10 10h-8V2Zm2 0v8h8A10 10 0 0 0 14 2Z" fill="currentColor"/></svg>',
      wallet: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 7a3 3 0 0 1 3-3h11v3H6v10h11v3H6a3 3 0 0 1-3-3V7Zm13 2h5v6h-5a3 3 0 1 1 0-6Zm0 2a1 1 0 1 0 0 2h3v-2h-3Z" fill="currentColor"/></svg>',
      settings: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m19.14 12.94.86-1.49-1.72-2.98-1.7.2a5.96 5.96 0 0 0-1.27-.73L14.5 6h-3l-.81 1.94c-.45.18-.88.42-1.27.73l-1.7-.2L6 11.45l.86 1.49c-.04.31-.06.64-.06.95s.02.64.06.95L6 16.33l1.72 2.98 1.7-.2c.39.31.82.55 1.27.73L11.5 22h3l.81-1.94c.45-.18.88-.42 1.27-.73l1.7.2L20 16.55l-.86-1.49c.04-.31.06-.64.06-.95s-.02-.64-.06-.95ZM13 16.5A2.5 2.5 0 1 1 13 11a2.5 2.5 0 0 1 0 5.5Z" fill="currentColor"/></svg>'
    }

    icons.fetch(name).html_safe
  end
end
