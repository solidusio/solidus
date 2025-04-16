export const debounce = (func, wait) => {
  let timeout

  return () => {
    clearTimeout(timeout)
    timeout = setTimeout(func, wait)
  }
}

export const setValidity = (element, error) => {
  if (!error) return;

  element.setCustomValidity(error);

  const clearValidity = () => {
    element.setCustomValidity("");
  }

  let clearOn;

  switch (element.tagName) {
    case "INPUT":
    case "TEXTAREA":
      clearOn = "input";
      break;
    case "SELECT":
      clearOn = "change";
      break;
  }

  element.addEventListener(clearOn, clearValidity, { once: true });
};

export function parseLinkHeader(header) {
  if (!header) return {};

  const links = {};
  header.split(",").forEach((link) => {
    // match against something like this '<https://example.com>; rel="next"'
    const match = link.match(/<([^>]+)>\s*;\s*rel="([^"]+)"/);
    if (match) {
      const [, url, rel] = match;
      links[rel] = url;
    }
  });

  return links;
}
