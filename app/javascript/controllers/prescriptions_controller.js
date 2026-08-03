import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "categoryInput", "categoryDropdown",
    "searchInput", "dropdown",
    "selectedTitle", "contentBox",
    "alert", "editor", "copyEditedBtn", "clearEditorBtn"
  ]
  static values = { data: String }

  connect() {
    this.allPrescriptions = JSON.parse(this.dataValue)
    this.categories = [...new Set(this.allPrescriptions.map(p => p.category))].sort()
    this.selectedCategory = null
    this.activePrescriptions = [...this.allPrescriptions]
    this.currentIndex = -1
    this.currentPrescription = null
    this.alertTimeout = null
    this.catHighlightIndex = -1
    this.prescHighlightIndex = -1

    if (this.hasEditorTarget) {
      this.editorTarget.addEventListener("input", () => this.onEditorChange())
    }
    document.addEventListener("click", (e) => this.handleOutsideClick(e))
  }

  // ─── CATEGORIA ───────────────────────────────────────────

  openCategory() {
    this.renderCategoryDropdown(this.categories)
  }

  searchCategory(event) {
    const query = event.target.value.trim().toLowerCase()
    const filtered = query
      ? this.categories.filter(c => c.toLowerCase().includes(query))
      : [...this.categories]
    this.renderCategoryDropdown(filtered)
  }

  renderCategoryDropdown(list) {
    const dropdown = this.categoryDropdownTarget
    dropdown.innerHTML = ""
    this.catHighlightIndex = -1

    if (list.length === 0) {
      dropdown.innerHTML = '<div class="px-5 py-3 text-sm text-[#94a3b8]">Nenhuma categoria encontrada</div>'
    } else {
      list.forEach((cat, i) => {
        const count = this.allPrescriptions.filter(p => p.category === cat).length
        const item = document.createElement("div")
        item.className = "px-5 py-3 cursor-pointer border-b border-[#ede9fe] last:border-b-0 text-sm text-[#1e293b] transition-all flex justify-between items-center"
        item.innerHTML = `<span>${cat}</span><span class="text-xs text-[#94a3b8]">${count}</span>`
        item.dataset.index = i
        item.addEventListener("click", () => this.selectCategory(cat))
        item.addEventListener("mouseenter", () => this.highlightItems(dropdown, i))
        dropdown.appendChild(item)
      })
    }
    dropdown.classList.remove("hidden")
  }

  selectCategory(cat) {
    this.selectedCategory = cat
    this.categoryInputTarget.value = cat
    this.categoryDropdownTarget.classList.add("hidden")
    this.activePrescriptions = this.allPrescriptions.filter(p => p.category === cat)
    this.currentIndex = -1
    this.currentPrescription = null
    // Limpa a busca de prescrição e refiltra
    this.searchInputTarget.value = ""
    this.searchInputTarget.focus()
  }

  clearCategory() {
    this.selectedCategory = null
    this.categoryInputTarget.value = ""
    this.activePrescriptions = [...this.allPrescriptions]
    this.currentIndex = -1
    this.currentPrescription = null
    this.searchInputTarget.value = ""
    this.categoryDropdownTarget.classList.add("hidden")
  }

  handleCategoryKey(event) {
    const dropdown = this.categoryDropdownTarget
    if (dropdown.classList.contains("hidden")) return
    const items = dropdown.querySelectorAll("[data-index]")

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.catHighlightIndex = Math.min(this.catHighlightIndex + 1, items.length - 1)
      this.highlightItems(dropdown, this.catHighlightIndex)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.catHighlightIndex = Math.max(this.catHighlightIndex - 1, 0)
      this.highlightItems(dropdown, this.catHighlightIndex)
    } else if (event.key === "Enter" && this.catHighlightIndex >= 0) {
      event.preventDefault()
      const filtered = this.categoryInputTarget.value.trim().toLowerCase()
        ? this.categories.filter(c => c.toLowerCase().includes(this.categoryInputTarget.value.trim().toLowerCase()))
        : this.categories
      if (filtered[this.catHighlightIndex]) this.selectCategory(filtered[this.catHighlightIndex])
    } else if (event.key === "Escape") {
      dropdown.classList.add("hidden")
    }
  }

  // ─── PRESCRIÇÃO ──────────────────────────────────────────

  openSearch() {
    this.renderPrescriptionDropdown(this.activePrescriptions)
  }

  search(event) {
    const query = event.target.value.trim().toLowerCase()
    const results = query
      ? this.activePrescriptions.filter(p => p.title.toLowerCase().includes(query))
      : [...this.activePrescriptions]
    this.renderPrescriptionDropdown(results)
  }

  renderPrescriptionDropdown(list) {
    const dropdown = this.dropdownTarget
    dropdown.innerHTML = ""
    this.prescHighlightIndex = -1

    if (list.length === 0) {
      dropdown.innerHTML = '<div class="px-5 py-3 text-sm text-[#94a3b8]">Nenhuma prescrição encontrada</div>'
    } else {
      list.slice(0, 100).forEach((p, i) => {
        const item = document.createElement("div")
        item.className = "px-5 py-3 cursor-pointer border-b border-[#ede9fe] last:border-b-0 text-sm text-[#1e293b] transition-all"
        item.textContent = p.title
        item.dataset.index = i
        item.addEventListener("click", () => this.selectPrescription(p))
        item.addEventListener("mouseenter", () => this.highlightItems(dropdown, i))
        dropdown.appendChild(item)
      })
    }
    dropdown.classList.remove("hidden")
  }

  selectPrescription(p) {
    this.currentPrescription = p
    this.currentIndex = this.activePrescriptions.findIndex(x => x.id === p.id)
    this.searchInputTarget.value = p.title
    this.dropdownTarget.classList.add("hidden")
    this.showPrescription(p)
  }

  clearSearch() {
    this.searchInputTarget.value = ""
    this.dropdownTarget.classList.add("hidden")
    this.searchInputTarget.focus()
  }

  handleKey(event) {
    const dropdown = this.dropdownTarget
    if (dropdown.classList.contains("hidden")) return
    const items = dropdown.querySelectorAll("[data-index]")

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.prescHighlightIndex = Math.min(this.prescHighlightIndex + 1, items.length - 1)
      this.highlightItems(dropdown, this.prescHighlightIndex)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.prescHighlightIndex = Math.max(this.prescHighlightIndex - 1, 0)
      this.highlightItems(dropdown, this.prescHighlightIndex)
    } else if (event.key === "Enter" && this.prescHighlightIndex >= 0) {
      event.preventDefault()
      const query = this.searchInputTarget.value.trim().toLowerCase()
      const visible = query
        ? this.activePrescriptions.filter(p => p.title.toLowerCase().includes(query))
        : this.activePrescriptions
      if (visible[this.prescHighlightIndex]) this.selectPrescription(visible[this.prescHighlightIndex])
    } else if (event.key === "Escape") {
      dropdown.classList.add("hidden")
    }
  }

  navigateNext() {
    if (!this.activePrescriptions.length) return
    this.currentIndex = (this.currentIndex + 1) % this.activePrescriptions.length
    const p = this.activePrescriptions[this.currentIndex]
    this.searchInputTarget.value = p.title
    this.showPrescription(p)
  }

  navigatePrev() {
    if (!this.activePrescriptions.length) return
    this.currentIndex = (this.currentIndex - 1 + this.activePrescriptions.length) % this.activePrescriptions.length
    const p = this.activePrescriptions[this.currentIndex]
    this.searchInputTarget.value = p.title
    this.showPrescription(p)
  }

  showPrescription(p) {
    this.currentPrescription = p
    this.selectedTitleTarget.textContent = p.title
    this.contentBoxTarget.innerHTML = p.content
  }

  // ─── CLIPBOARD / EDITOR ──────────────────────────────────

  copyPrescription() {
    if (!this.currentPrescription) return
    navigator.clipboard.writeText(this.contentBoxTarget.innerText).then(() => this.showAlert())
  }

  addToEditor() {
    if (!this.currentPrescription || !this.hasEditorTarget) return
    const text = this.contentBoxTarget.innerText
    const current = this.editorTarget.innerText.trim()
    this.editorTarget.innerText = current ? current + "\n\n" + text : text
    this.updateEditorButtons()
    this.showAlert("✓ Adicionado ao editor!")
  }

  copyEdited() {
    if (!this.hasEditorTarget) return
    navigator.clipboard.writeText(this.editorTarget.innerText).then(() => this.showAlert())
  }

  clearEditor() {
    if (!this.hasEditorTarget) return
    this.editorTarget.innerText = ""
    this.updateEditorButtons()
  }

  onEditorChange() { this.updateEditorButtons() }

  updateEditorButtons() {
    if (!this.hasEditorTarget) return
    const hasContent = this.editorTarget.innerText.trim().length > 0
    this.copyEditedBtnTarget.classList.toggle("hidden", !hasContent)
    this.clearEditorBtnTarget.classList.toggle("hidden", !hasContent)
  }

  // ─── UTILITÁRIOS ─────────────────────────────────────────

  highlightItems(dropdown, activeIndex) {
    dropdown.querySelectorAll("[data-index]").forEach((item, i) => {
      if (i === activeIndex) {
        item.style.background = "linear-gradient(135deg, rgba(139,92,246,0.08), rgba(217,70,239,0.06))"
        item.style.color = "#7c3aed"
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.style.background = ""
        item.style.color = ""
      }
    })
  }

  handleOutsideClick(e) {
    if (!this.element.contains(e.target)) {
      this.categoryDropdownTarget.classList.add("hidden")
      this.dropdownTarget.classList.add("hidden")
    }
  }

  showAlert(message = "✓ Copiado para a área de transferência!") {
    const alert = this.alertTarget
    alert.textContent = message
    alert.classList.remove("hidden")
    clearTimeout(this.alertTimeout)
    this.alertTimeout = setTimeout(() => alert.classList.add("hidden"), 2000)
  }
}
