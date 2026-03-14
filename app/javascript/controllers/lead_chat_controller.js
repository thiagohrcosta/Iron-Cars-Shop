import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "iron-cars-lead-chat-v1"

export default class extends Controller {
  static targets = ["badge", "form", "input", "launcher", "messages", "panel", "restart", "submit"]
  static values = {
    endpoint: String,
    initialMessage: String
  }

  connect() {
    this.restartPromptVisible = false
    this.state = this.loadState()
    this.ensureInitialMessage()
    this.renderMessages()
    this.updateBadge()
    this.updateConversationState()
  }

  toggle() {
    const isHidden = this.panelTarget.hidden
    this.panelTarget.hidden = !isHidden
    this.launcherTarget.setAttribute("aria-expanded", String(isHidden))

    if (isHidden) {
      this.state.unreadCount = 0
      this.persistState()
      this.updateBadge()
      if (this.restartPromptVisible) {
        this.restartTarget.querySelector("button")?.focus()
      } else {
        this.focusInput()
        this.scrollToBottom()
      }
    }
  }

  async sendMessage(event) {
    event.preventDefault()
    if (this.restartPromptVisible) return

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

      if (payload.conversation_closed === true) {
        this.handleConversationClosed()
      } else {
        this.pushMessage("assistant", payload.assistant_message)
        this.state.leadCreated = payload.lead_created
        this.state.collected = payload.collected || {}
        this.persistState()
        this.updateConversationState()
        this.scrollToBottom()
      }
    } catch (_error) {
      this.pushMessage("assistant", "I had a small issue on my side. Please try again in a moment.")
    } finally {
      this.setLoading(false)
    }
  }

  startNewChat() {
    this.restartPromptVisible = false
    this.state = this.defaultState()
    this.ensureInitialMessage()
    this.renderMessages()
    this.updateBadge()
    this.updateConversationState()
    this.focusInput()
  }

  ensureInitialMessage() {
    if (this.state.messages.length > 0) return

    this.state.messages.push({ role: "assistant", content: this.initialMessageValue })
    this.state.unreadCount = 1
    this.persistState()
  }

  pushMessage(role, content) {
    this.state.messages.push({ role, content })
    if (role === "assistant" && this.panelTarget.hidden) {
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
    this.badgeTarget.hidden = count === 0
  }

  setLoading(isLoading) {
    if (this.state.conversationClosed) {
      this.updateConversationState()
      return
    }

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

  clearPersistedState() {
    localStorage.removeItem(STORAGE_KEY)
  }

  loadState() {
    try {
      const state = JSON.parse(localStorage.getItem(STORAGE_KEY))
      return state?.conversationClosed ? this.defaultState() : (state || this.defaultState())
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

  updateConversationState() {
    this.messagesTarget.hidden = this.restartPromptVisible
    this.restartTarget.hidden = !this.restartPromptVisible
    this.formTarget.hidden = this.restartPromptVisible
    this.inputTarget.disabled = false
    this.submitTarget.disabled = false
    this.inputTarget.placeholder = "Type your message"
    this.submitTarget.textContent = "Send"
  }

  handleConversationClosed() {
    this.restartPromptVisible = true
    this.state = this.defaultState()
    this.clearPersistedState()
    this.renderMessages()
    this.updateBadge()
    this.updateConversationState()
  }
}
