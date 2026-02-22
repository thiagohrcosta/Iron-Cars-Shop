import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "vin",
    "vinStatus",
    "brand",
    "model",
    "year",
    "mileage",
    "transmission",
    "fuelType",
    "drivetrain",
    "doors",
    "seats",
    "titleStatus",
    "price",
    "photos",
    "photoCount",
    "photoGallery",
    "previewImage",
    "previewPrice",
    "previewName",
    "previewMileage",
    "previewSpecs",
    "previewTitle"
  ]

  static values = { modelsByBrand: Object }

  connect() {
    this.populateModels()
    this.checkVin()
    this.updatePreview()
  }

  brandChanged() {
    this.populateModels()
    this.updatePreview()
  }

  checkVin() {
    if (!this.hasVinTarget || !this.hasVinStatusTarget) return

    const isValid = /^\d{17}$/.test(this.vinTarget.value)
    if (this.vinTarget.value.length === 0) {
      this.vinStatusTarget.textContent = "VIN must contain exactly 17 digits."
      this.vinStatusTarget.className = "mt-2 text-sm text-slate-500"
      return
    }

    if (isValid) {
      this.vinStatusTarget.textContent = "VIN valid!"
      this.vinStatusTarget.className = "mt-2 text-sm text-emerald-600"
    } else {
      this.vinStatusTarget.textContent = "VIN invalid. Use exactly 17 digits."
      this.vinStatusTarget.className = "mt-2 text-sm text-red-600"
    }
  }

  photosChanged(event) {
    const files = Array.from(event.target.files || [])
    const imageFiles = files.filter((file) => file.type.startsWith("image/"))

    this.photoCountTarget.textContent = imageFiles.length > 0
      ? `${imageFiles.length} photo(s) selected`
      : "No photos selected"

    this.photoGalleryTarget.innerHTML = ""

    imageFiles.slice(0, 4).forEach((file, index) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        const wrapper = document.createElement("div")
        wrapper.className = "rounded-lg overflow-hidden border border-slate-200"

        const image = document.createElement("img")
        image.src = e.target.result
        image.className = "h-20 w-full object-cover"

        wrapper.appendChild(image)
        this.photoGalleryTarget.appendChild(wrapper)

        if (index === 0) {
          this.previewImageTarget.src = e.target.result
        }
      }

      reader.readAsDataURL(file)
    })

    if (imageFiles.length > 4) {
      const extra = document.createElement("div")
      extra.className = "rounded-lg border border-slate-200 bg-slate-100 h-20 flex items-center justify-center text-sm font-semibold text-slate-600"
      extra.textContent = `+${imageFiles.length - 4}`
      this.photoGalleryTarget.appendChild(extra)
    }
  }

  updatePreview() {
    const year = this.selectedText(this.yearTarget) || "Year"
    const brand = this.selectedText(this.brandTarget) || "Brand"
    const model = this.selectedText(this.modelTarget) || "Model"

    this.previewNameTarget.textContent = `${year} ${brand} ${model}`

    const mileageValue = this.mileageTarget.value
    const mileageLabel = mileageValue ? `${Number(mileageValue).toLocaleString()} miles` : "0 miles"
    this.previewMileageTarget.textContent = mileageLabel

    const transmission = this.selectedText(this.transmissionTarget) || "Transmission"
    const drivetrain = this.selectedText(this.drivetrainTarget) || "Drivetrain"
    const fuelType = this.selectedText(this.fuelTypeTarget) || "Fuel Type"
    const doors = this.selectedText(this.doorsTarget)
    const seats = this.selectedText(this.seatsTarget)
    const doorsText = doors ? `${doors} doors` : "Doors"
    const seatsText = seats ? `${seats} seats` : "Seats"

    this.previewSpecsTarget.textContent = `${transmission} · ${fuelType} · ${drivetrain} · ${doorsText} · ${seatsText}`

    const titleStatus = this.selectedText(this.titleStatusTarget) || "Title"
    this.previewTitleTarget.textContent = `${titleStatus} Title`

    const priceValue = this.priceTarget.value
    const parsedPrice = Number(priceValue)
    const formattedPrice = Number.isNaN(parsedPrice) || priceValue === ""
      ? "$0"
      : new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 }).format(parsedPrice)

    this.previewPriceTarget.textContent = formattedPrice
  }

  populateModels() {
    const brandId = this.brandTarget.value
    const currentModel = this.modelTarget.value
    const models = this.modelsByBrandValue[brandId] || []

    this.modelTarget.innerHTML = ""
    this.modelTarget.add(new Option("Select Model", ""))

    models.forEach(([name, id]) => {
      this.modelTarget.add(new Option(name, id))
    })

    this.modelTarget.disabled = models.length === 0

    const hasCurrent = models.some(([, id]) => String(id) === String(currentModel))
    if (hasCurrent) this.modelTarget.value = currentModel
  }

  selectedText(selectElement) {
    if (!selectElement) return ""
    const selectedOption = selectElement.options[selectElement.selectedIndex]
    if (!selectedOption) return ""
    return selectedOption.textContent.trim()
  }
}
