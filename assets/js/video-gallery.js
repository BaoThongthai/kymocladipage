(function () {
  const container = document.getElementById('youtube-video-list');
  const section = document.getElementById('videos');
  const links = Array.isArray(window.KY_MOC_YOUTUBE_VIDEOS)
    ? window.KY_MOC_YOUTUBE_VIDEOS
    : [];

  if (!container || !section) return;

  const videoIds = links.map(getYoutubeId).filter(Boolean);

  if (videoIds.length === 0) {
    section.hidden = true;
    return;
  }

  container.innerHTML = videoIds.map((videoId, index) => `
    <div class="col-lg-6 col-md-10">
      <div class="video-card">
        <div class="video-frame">
          <iframe
            src="https://www.youtube-nocookie.com/embed/${videoId}"
            title="Video sản phẩm Kỷ Mộc ${index + 1}"
            loading="lazy"
            referrerpolicy="strict-origin-when-cross-origin"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            allowfullscreen></iframe>
        </div>
      </div>
    </div>`).join('');

  function getYoutubeId(link) {
    if (typeof link !== 'string' || !link.trim()) return null;

    try {
      const url = new URL(link.trim());
      const host = url.hostname.replace(/^www\./, '').replace(/^m\./, '');

      if (host === 'youtu.be') return validId(url.pathname.split('/')[1]);
      if (host !== 'youtube.com' && host !== 'youtube-nocookie.com') return null;

      if (url.pathname === '/watch') return validId(url.searchParams.get('v'));

      const parts = url.pathname.split('/').filter(Boolean);
      if (['embed', 'shorts', 'live'].includes(parts[0])) return validId(parts[1]);
    } catch (error) {
      return validId(link.trim());
    }

    return null;
  }

  function validId(value) {
    return /^[a-zA-Z0-9_-]{11}$/.test(value || '') ? value : null;
  }
})();
