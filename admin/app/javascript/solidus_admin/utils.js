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
