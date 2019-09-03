import docsearch from "docsearch.js"

const input = document.querySelector('#inputSearch')
const label = document.querySelector('label[for="inputSearch"]')

docsearch({
  apiKey: 'a021104be0e00dbc782914786fc9fdec',
  indexName: 'solidus',
  inputSelector: '#inputSearch',
  autocompleteOptions: {
    autoWidth: false,
    openOnFocus: true,
    autoselect: true
  }
})

input.addEventListener('focus', () => {
  input.classList.remove('placeholder-shown')
  label.classList.add('input-focused')
})

input.form.addEventListener('submit', (event) => {
  event.preventDefault()
  return false
})

input.addEventListener('blur', () => {
  if (input.value === '') {
    input.classList.add('placeholder-shown')
    label.classList.remove('input-focused')
  }
})

document.addEventListener('DOMContentLoaded', () => {
  input.value = ''
})
