import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step1", "step2", "step1Indicator", "step2Indicator", "country", "state"]
  static values = { statesByCountry: Object }

  connect() {
    this.populateStates()
    this.showStepFromErrorsOrData()
  }

  next() {
    if (!this.validateStepOne()) return

    this.step1Target.classList.add("hidden")
    this.step2Target.classList.remove("hidden")

    this.step1Indicator.classList.remove("bg-blue-600")
    this.step1Indicator.classList.add("bg-slate-300")

    this.step2Indicator.classList.remove("bg-slate-300")
    this.step2Indicator.classList.add("bg-blue-600")
  }

  countryChanged() {
    this.populateStates()
  }

  validateStepOne() {
    const fields = this.step1Target.querySelectorAll("input")
    for (const field of fields) {
      if (!field.checkValidity()) {
        field.reportValidity()
        return false
      }
    }

    return true
  }

  populateStates() {
    if (!this.hasCountryTarget || !this.hasStateTarget) return

    const selectedCountry = this.countryTarget.value
    const selectedState = this.stateTarget.value
    const states = this.statesByCountryValue[selectedCountry] || []

    this.stateTarget.innerHTML = ""
    this.stateTarget.add(new Option("Select state/province", ""))

    states.forEach(([name, code]) => {
      this.stateTarget.add(new Option(name, code))
    })

    this.stateTarget.disabled = states.length === 0
    if (states.some(([, code]) => code === selectedState)) {
      this.stateTarget.value = selectedState
    }
  }

  showStepFromErrorsOrData() {
    if (!this.hasStep2Target) return

    const hasStepTwoValues = this.step2Target.querySelectorAll("input, select")
      .length > 0 &&
      Array.from(this.step2Target.querySelectorAll("input, select")).some((field) => field.value)

    if (hasStepTwoValues) {
      this.next()
    }
  }
}