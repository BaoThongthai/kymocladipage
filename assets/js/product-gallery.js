(function () {
  const container = document.getElementById('portfolio-products');
  const products = Array.isArray(window.KY_MOC_PRODUCTS) ? window.KY_MOC_PRODUCTS : [];

  if (!container || products.length === 0) return;

  const messengerUrl = 'https://m.me/noithatkymocdn';

  container.innerHTML = products.map((product) => {
    const path = product.path.split('/').map(encodeURIComponent).join('/');
    const title = escapeHtml(product.title);
    const description = escapeHtml(product.description);
    const category = escapeHtml(product.category);
    const gallery = escapeHtml(product.gallery);

    return `
      <div class="col-lg-4 col-md-6 portfolio-item isotope-item ${category}">
        <div class="portfolio-content h-100">
          <img src="${path}" class="img-fluid" alt="${title}" loading="lazy">
          <div class="portfolio-info">
            <h4>${title}</h4>
            <p>${description}</p>
            <a href="${path}" title="${title}" data-gallery="${gallery}"
              class="glightbox preview-link"><i class="bi bi-zoom-in"></i></a>
            <a href="${messengerUrl}" title="Liên hệ" class="details-link"><i
              class="bi bi-link-45deg"></i></a>
          </div>
        </div>
      </div>`;
  }).join('');

  function escapeHtml(value) {
    return String(value).replace(/[&<>'"]/g, (character) => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      "'": '&#39;',
      '"': '&quot;'
    })[character]);
  }
})();
