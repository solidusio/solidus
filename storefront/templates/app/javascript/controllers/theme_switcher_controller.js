import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["themeSwitch"]
  
  toggleTheme() {
    const lsTheme = localStorage.getItem('theme') || 'light'
    let currentTheme

    if (lsTheme === 'light') {
      currentTheme = 'dark'
      document.documentElement.classList.remove('light')
    } else {
      currentTheme = 'light'
      document.documentElement.classList.remove('dark')
    }
    
    document.documentElement.classList.add(currentTheme)
    localStorage.setItem('theme', currentTheme)
  }
}