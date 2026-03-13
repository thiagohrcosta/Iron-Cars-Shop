import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input"]

  connect() {
    this.scrollToBottom()
    this.observeNewMessages()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  onSubmitEnd(event) {
    if (!event.detail.success) return

    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.style.height = ""
    }

    this.scrollToBottom()
  }

  observeNewMessages() {
    if (!this.hasMessagesTarget) return

    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    this.observer.observe(this.messagesTarget, { childList: true })
  }

  scrollToBottom() {
    if (!this.hasMessagesTarget) return

    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
