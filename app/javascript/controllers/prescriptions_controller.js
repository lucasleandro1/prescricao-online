import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput", "dropdown", "selectedTitle", "contentBox",
    "alert", "editor", "copyEditedBtn", "clearEditorBtn"
  ]
  static values = { data: String }

  connect() {
    this.allPrescriptions = JSON.parse(this.dataValue)
    this.filteredPrescriptions = [...this.allPrescriptions]
    this.currentIndex = -1
    this.highlightedIndex = -1
    this.currentPrescription = null
    this.alertTimeout = null

    this.editorTarget.addEventListener("input", () => this.onEditorChange())
    document.addEventListener("click", (e) => this.handleOutsideClick(e))
  }

  search(event) {
    const query = event.target.value.trim().toLowerCase()
    if (!query) {
      this.filteredPrescriptions = [...this.allPrescriptions]
      this.closeDropdown()
      return
    }
    this.filteredPrescriptions = this.allPrescriptions.filter(p =>
      p.title.toLowerCase().includes(query)
    )
    this.renderDropdown()
  }

  renderDropdown() {
    const dropdown = this.dropdownTarget
    dropdown.innerHTML = ""
    this.highlightedIndex = -1

    if (this.filteredPrescriptions.length === 0) {
      dropdown.innerHTML = '<div class="px-5 py-3 text-sm text-[#94a3b8]">Nenhuma prescrição encontrada</div>'
    } else {
      this.filteredPrescriptions.slice(0, 100).forEach((p, i) => {
        const item = document.createElement("div")
        item.className = "px-5 py-3 cursor-pointer transition-all border-b border-[#f1f5f9] last:border-b-0 text-sm text-[#1e293b] hover:text-blue-500"
        item.style.cssText = "hover:background:linear-gradient(135deg,rgba(59,130,246,.05),rgba(6,182,212,.05))"
        item.textContent = p.title
        item.dataset.index = i
        item.addEventListener("click", () => this.selectFromDropdown(i))
        item.addEventListener("mouseenter", () => {
          item.style.background = "linear-gradient(135deg, rgba(59,130,246,0.05) 0%, rgba(6,182,212,0.05) 100%)"
          item.style.color = "#3b82f6"
          this.highlightedIndex = i
        })
        item.addEventListener("mouseleave", () => {
          item.style.background = ""
          item.style.color = ""
        })
        dropdown.appendChild(item)
      })
    }
    dropdown.classList.remove("hidden")
  }

  closeDropdown() {
    this.dropdownTarget.classList.add("hidden")
  }

  handleOutsideClick(e) {
    if (!this.element.contains(e.target)) {
      this.closeDropdown()
    }
  }

  handleKey(event) {
    if (!this.dropdownTarget.classList.contains("hidden")) {
      const items = this.dropdownTarget.querySelectorAll("[data-index]")
      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.highlightedIndex = Math.min(this.highlightedIndex + 1, items.length - 1)
        this.updateDropdownHighlight(items)
      } else if (event.key === "ArrowUp") {
        event.preventDefault()
        this.highlightedIndex = Math.max(this.highlightedIndex - 1, 0)
        this.updateDropdownHighlight(items)
      } else if (event.key === "Enter" && this.highlightedIndex >= 0) {
        event.preventDefault()
        this.selectFromDropdown(this.highlightedIndex)
      } else if (event.key === "Escape") {
        this.closeDropdown()
      }
    }
  }

  updateDropdownHighlight(items) {
    items.forEach((item, i) => {
      if (i === this.highlightedIndex) {
        item.style.background = "linear-gradient(135deg, rgba(59,130,246,0.05) 0%, rgba(6,182,212,0.05) 100%)"
        item.style.color = "#3b82f6"
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.style.background = ""
        item.style.color = ""
      }
    })
  }

  selectFromDropdown(index) {
    const selected = this.filteredPrescriptions[index]
    if (!selected) return
    const globalIndex = this.allPrescriptions.findIndex(p => p.id === selected.id)
    this.currentIndex = globalIndex
    this.showPrescription(globalIndex)
    this.searchInputTarget.value = selected.title
    this.filteredPrescriptions = [...this.allPrescriptions]
    this.closeDropdown()
  }

  clearSearch() {
    this.searchInputTarget.value = ""
    this.filteredPrescriptions = [...this.allPrescriptions]
    this.closeDropdown()
    this.searchInputTarget.focus()
  }

  navigateNext() {
    if (this.allPrescriptions.length === 0) return
    this.currentIndex = (this.currentIndex + 1) % this.allPrescriptions.length
    this.showPrescription(this.currentIndex)
  }

  navigatePrev() {
    if (this.allPrescriptions.length === 0) return
    this.currentIndex = (this.currentIndex - 1 + this.allPrescriptions.length) % this.allPrescriptions.length
    this.showPrescription(this.currentIndex)
  }

  showPrescription(index) {
    const p = this.allPrescriptions[index]
    if (!p) return
    this.selectedTitleTarget.textContent = p.title
    this.contentBoxTarget.innerHTML = p.content
    this.currentPrescription = p
  }

  copyPrescription() {
    if (!this.currentPrescription) return
    const text = this.contentBoxTarget.innerText
    navigator.clipboard.writeText(text).then(() => this.showAlert())
  }

  addToEditor() {
    if (!this.currentPrescription) return
    const text = this.contentBoxTarget.innerText
    const current = this.editorTarget.innerText.trim()
    this.editorTarget.innerText = current ? current + "\n\n" + text : text
    this.updateEditorButtons()
    this.showAlert("✓ Adicionado ao editor!")
  }

  copyEdited() {
    const text = this.editorTarget.innerText
    navigator.clipboard.writeText(text).then(() => this.showAlert())
  }

  clearEditor() {
    this.editorTarget.innerText = ""
    this.updateEditorButtons()
  }

  onEditorChange() {
    this.updateEditorButtons()
  }

  updateEditorButtons() {
    const hasContent = this.editorTarget.innerText.trim().length > 0
    this.copyEditedBtnTarget.classList.toggle("hidden", !hasContent)
    this.clearEditorBtnTarget.classList.toggle("hidden", !hasContent)
  }

  showAlert(message = "✓ Copiado para a área de transferência!") {
    const alert = this.alertTarget
    alert.textContent = message
    alert.classList.remove("hidden")
    clearTimeout(this.alertTimeout)
    this.alertTimeout = setTimeout(() => alert.classList.add("hidden"), 2000)
  }
}
