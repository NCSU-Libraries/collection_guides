class ThumbnailGallery {

  constructor(config) {
    this.#initialize(config);
  }

  #initialize(config) {
    this.thumbnailViewers = document.getElementsByClassName('thumbnail-viewer');
    this.totalThumbnailViewers = this.thumbnailViewers.length;

    if (this.totalThumbnailViewers > 0) {
      this.#activateThumbnailViewers();
    }
  }

  #activateThumbnailViewers() {
    let viewerConfig = {
      thumbnailMaxWidth: 90
    }

    for (let i = 0; i < this.totalThumbnailViewers; i++) {
      const viewerContainer = this.thumbnailViewers[i];
      
      if (viewerContainer) {
        viewerConfig['selector'] = "#" + viewerContainer.id;
        const viewer = new ThumbnailViewer(viewerConfig);
      }
    }
  }
}
