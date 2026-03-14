import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "form", "hiddenInputs", "input", "method", "modal", "name", "phone", "preview", "sourceLabel", "submit", "tags", "title"]
  static values = {
    initialTags: Array,
    open: Boolean
  }

  connect() {
    this.tags = [ ...(this.initialTagsValue || []) ]
    this.renderTags()
    this.prepareCreateForm()
    this.toggleModal(this.openValue)
  }

  openCreate() {
    this.prepareCreateForm()
    this.tags = []
    this.renderTags()
    this.resetFields()
    this.updateDraft()
    this.openModal()
  }

  openEdit(event) {
    const button = event.currentTarget
    this.prepareEditForm(button)
    this.tags = this.parseTags(button.dataset.leadInterestedIn)
    this.renderTags()
    this.inputTarget.value = ""
    this.updateDraft()
    this.openModal()
  }

  openModal() {
    this.toggleModal(true)
    this.inputTarget.focus()
  }

  close() {
    this.toggleModal(false)
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  updateDraft() {
    const value = this.inputTarget.value.trim()
    this.previewTarget.hidden = value.length === 0
    this.previewTarget.textContent = value.length === 0 ? "" : `Press Enter to add: ${value}`
  }

  maybeAddTag(event) {
    if (event.key !== "Enter" && event.key !== ",") return

    event.preventDefault()
    this.commitCurrentTag()
  }

  addCurrentTag(event) {
    event.preventDefault()
    this.commitCurrentTag()
  }

  removeTag(event) {
    const value = event.currentTarget.dataset.value
    this.tags = this.tags.filter((tag) => tag !== value)
    this.renderTags()
  }

  commitCurrentTag() {
    const value = this.inputTarget.value.trim().replace(/,+$/, "")
    if (!value || this.tags.includes(value)) return

    this.tags = [ ...this.tags, value ]
    this.inputTarget.value = ""
    this.renderTags()
    this.updateDraft()
  }

  renderTags() {
    this.tagsTarget.innerHTML = ""
    this.hiddenInputsTarget.innerHTML = ""

    this.tags.forEach((tag) => {
      const chip = document.createElement("button")
      chip.type = "button"
      chip.className = "rounded-full bg-blue-50 px-3 py-1.5 text-sm font-medium text-blue-700 transition hover:bg-blue-100"
      chip.dataset.value = tag
      chip.dataset.action = "manual-lead#removeTag"
      chip.textContent = `${tag} ×`
      this.tagsTarget.appendChild(chip)

      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "lead[interested_in][]"
      input.value = tag
      this.hiddenInputsTarget.appendChild(input)
    })
  }

  toggleModal(show) {
    this.modalTarget.hidden = !show
    document.body.classList.toggle("overflow-hidden", show)
  }

  prepareCreateForm() {
    if (!this.hasFormTarget) return

    this.formTarget.action = this.formTarget.dataset.createUrl
    this.methodTarget.value = "post"
    this.titleTarget.textContent = "Create Manual Lead"
    this.submitTarget.value = "Create Lead"
    this.sourceLabelTarget.textContent = "Referral"
  }

  prepareEditForm(button) {
    this.formTarget.action = button.dataset.leadUpdateUrl
    this.methodTarget.value = "patch"
    this.titleTarget.textContent = "Edit Lead"
    this.submitTarget.value = "Save Changes"
    this.sourceLabelTarget.textContent = button.dataset.leadSourceLabel || "Referral"
    this.nameTarget.value = button.dataset.leadName || ""
    this.emailTarget.value = button.dataset.leadEmail || ""
    this.phoneTarget.value = button.dataset.leadPhone || ""
  }

  resetFields() {
    this.nameTarget.value = ""
    this.emailTarget.value = ""
    this.phoneTarget.value = ""
  }

  parseTags(raw) {
    if (!raw) return []

    try {
      return JSON.parse(raw)
    } catch {
      return []
    }
  }
}
