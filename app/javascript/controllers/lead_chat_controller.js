import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "iron-cars-lead-chat-v1"

export default class extends Controller {
  static targets = ["badge", "input", "launcher", "messages", "panel", "submit"]
  static values = {
    endpoint: String,
    initialMessage: String
  }

  connect() {
    this.state = this.loadState()
    this.ensureInitialMessage()
    this.renderMessages()
    this.updateBadge()
  }

  toggle() {
    const isHidden = this.panelTarget.classList.contains("hidden")
    this.panelTarget.classList.toggle("hidden")
    this.launcherTarget.setAttribute("aria-expanded", String(isHidden))

    if (isHidden) {
      this.state.unreadCount = 0
      this.persistState()
      this.updateBadge()
      this.focusInput()
      this.scrollToBottom()
    }
  }

  async sendMessage(event) {
    event.preventDefault()

    const message = this.inputTarget.value.trim()
    if (!message) return

    this.pushMessage("user", message)
    this.inputTarget.value = ""
    this.setLoading(true)

    try {
      const response = await fetch(this.endpointValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({ message })
      })

      const payload = await response.json()
      if (!response.ok) throw new Error(payload.error || "Unable to continue chat")

      this.pushMessage("assistant", payload.assistant_message)
      this.state.leadCreated = payload.lead_created
      this.state.collected = payload.collected || {}
      this.persistState()
      this.scrollToBottom()
    } catch (_error) {
      this.pushMessage("assistant", "I had a small issue on my side. Please try again in a moment.")
    } finally {
      this.setLoading(false)
    }
  }

  ensureInitialMessage() {
    if (this.state.messages.length > 0) return

    this.state.messages.push({ role: "assistant", content: this.initialMessageValue })
    this.state.unreadCount = 1
    this.persistState()
  }

  pushMessage(role, content) {
    this.state.messages.push({ role, content })
    if (role === "assistant" && this.panelTarget.classList.contains("hidden")) {
      this.state.unreadCount = (this.state.unreadCount || 0) + 1
    }

    this.persistState()
    this.renderMessages()
    this.updateBadge()
  }

  renderMessages() {
    this.messagesTarget.innerHTML = ""

    this.state.messages.forEach((message) => {
      const article = document.createElement("article")
      article.className = `lead-chat__message lead-chat__message--${message.role}`
      article.textContent = message.content
      this.messagesTarget.appendChild(article)
    })

    this.scrollToBottom()
  }

  updateBadge() {
    const count = this.state.unreadCount || 0
    this.badgeTarget.textContent = count
    this.badgeTarget.classList.toggle("hidden", count === 0)
  }

  setLoading(isLoading) {
    this.submitTarget.disabled = isLoading
    this.inputTarget.disabled = isLoading
    this.submitTarget.textContent = isLoading ? "..." : "Send"
  }

  focusInput() {
    this.inputTarget.focus()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  persistState() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state))
  }

  loadState() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || this.defaultState()
    } catch (_error) {
      return this.defaultState()
    }
  }

  defaultState() {
    return { messages: [], unreadCount: 0, collected: {}, leadCreated: false }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
