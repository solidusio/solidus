window.addEventListener('DOMContentLoaded', () => {
  const radios = document.querySelectorAll("[data-js='variant-radio']");
  const thumbnailsLinks = document
    .querySelectorAll("[data-js='product-thumbnail'] a, [data-js='variant-thumbnail'] a");
  const productImage = document.querySelector("[data-js='product-main-image']");
  const variantsThumbnails = document.querySelectorAll("[data-js='variant-thumbnail']");

  if (radios.length > 0) {
    const selectedRadio = document.querySelector("[data-js='variant-radio'][checked='checked']");
    updateVariantPrice(selectedRadio);
    updateVariantImages(selectedRadio.value);
  }

  radios.forEach(radio => {
    radio.addEventListener('click', () => {
      updateVariantPrice(radio);
      updateVariantImages(radio.value);
    });
  });

  thumbnailsLinks.forEach(thumbnailLink => {
    thumbnailLink.addEventListener('click', (event) => {
      event.preventDefault();
      updateProductImage(thumbnailLink.href);
    });
  });

  function updateVariantPrice(variant) {
    const variantPrice = variant.dataset.jsPrice;
    if (variantPrice) {
      document.querySelector("[data-js='price']").innerHTML = variantPrice;
    }
  };

  function updateVariantImages(variantId) {
    selector = "[data-js='variant-thumbnail'][data-js-id='" + variantId + "']";
    variantsThumbnailsToDisplay = document.querySelectorAll(selector);

    variantsThumbnails.forEach(thumbnail => {
      thumbnail.style.display = 'none';
    });

    variantsThumbnailsToDisplay.forEach(thumbnail => {
      thumbnail.style.display = 'list-item';
    });

    if(variantsThumbnailsToDisplay.length) {
      variantFirstImage = variantsThumbnailsToDisplay[0].querySelector('a').href
      updateProductImage(variantFirstImage);
    }
  };

  function updateProductImage(imageSrc) {
    productImage.src = imageSrc;
  }
});
