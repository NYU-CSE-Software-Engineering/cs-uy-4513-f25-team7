// app/javascript/controllers/slot_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "speciesId","speciesName","speciesOptions",
        "abilityId","abilityName","abilityOptions",
        "itemId","itemName","itemOptions",
        "moveId","moveName",
        "sprite"
    ]
    static values = { position: Number }

    onSubmit() {
        // Species
        if (this.hasSpeciesIdTarget && this.hasSpeciesNameTarget && this.hasSpeciesOptionsTarget) {
            if (!this.speciesIdTarget.value) {
                const opt = this.pickFromDatalist(this.speciesNameTarget, this.speciesOptionsTarget)
                if (opt) this.speciesIdTarget.value = opt.dataset.id || ""
            }
        }

        // Ability
        if (this.hasAbilityIdTarget && this.hasAbilityNameTarget && this.hasAbilityOptionsTarget) {
            if (!this.abilityIdTarget.value) {
                const opt = this.pickFromDatalist(this.abilityNameTarget, this.abilityOptionsTarget)
                if (opt) this.abilityIdTarget.value = opt.dataset.id || ""
            }
        }

        // Item
        if (this.hasItemIdTarget && this.hasItemNameTarget && this.hasItemOptionsTarget) {
            if (!this.itemIdTarget.value) {
                const opt = this.pickFromDatalist(this.itemNameTarget, this.itemOptionsTarget)
                if (opt) this.itemIdTarget.value = opt.dataset.id || ""
            }
        }

        // Moves (each row)
        this.element.querySelectorAll(".move-row").forEach((row) => {
            const input   = row.querySelector("[data-slot-target='moveName']")
            const options = row.querySelector("datalist")
            const hidden  = row.querySelector("input[type='hidden'][name$='[move_id]']")
            if (input && options && hidden && !hidden.value) {
                const val = input.value.toLowerCase()
                const opt = Array.from(options.options).find(o => o.value.toLowerCase() === val)
                if (opt) hidden.value = opt.dataset.id || ""
            }
        })
    }

    // --- helpers ---
    async fetchJSON(url) {
        const res = await fetch(url)
        if (!res.ok) return []
        return await res.json()
    }
    setDatalist(optionsEl, items) {
        // default renderer (id + name)
        optionsEl.innerHTML = items.map(i => `<option data-id="${i.id}" value="${i.name}"></option>`).join("")
    }
    pickFromDatalist(inputEl, optionsEl) {
        const val = inputEl.value.toLowerCase()
        const opt = Array.from(optionsEl.options).find(o => o.value.toLowerCase() === val)
        return opt || null
    }

    // --- species ---
    async searchSpecies(e){
        const q = e.target.value.trim()
        if (q.length < 2) return
        const items = await this.fetchJSON(`/api/lookup/species?q=${encodeURIComponent(q)}`) // [{id,name,pokeapi_id}]
        // include pokeapi_id as a data attribute
        this.speciesOptionsTarget.innerHTML = items.map(sp =>
            `<option value="${sp.name}" data-id="${sp.id}" data-pokeapi-id="${sp.pokeapi_id || ''}"></option>`
        ).join("")
    }

    async commitSpecies(e){
        const opt = this.pickFromDatalist(this.speciesNameTarget, this.speciesOptionsTarget)
        if (opt) {
            const id = opt.dataset.id
            const pokeapiId = opt.dataset.pokeapiId
            this.speciesIdTarget.value = id || ""

            // Preload learnset to bias move suggestions
            this.learnset = await this.fetchJSON(`/api/lookup/learnset?species_id=${id}&format=sv`)

            // Set sprite if we have one
            if (this.hasSpriteTarget) {
                if (pokeapiId) {
                    // High-res official artwork (nice in UIs)
                    this.spriteTarget.src = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokeapiId}.png`
                    this.spriteTarget.alt = this.speciesNameTarget.value
                } else {
                    this.spriteTarget.removeAttribute("src")
                    this.spriteTarget.alt = "sprite"
                }
            }
        } else {
            this.speciesIdTarget.value = ""
            this.learnset = []
            if (this.hasSpriteTarget) {
                this.spriteTarget.removeAttribute("src")
                this.spriteTarget.alt = "sprite"
            }
        }
    }

    // --- abilities ---
    async searchAbilities(e){
        const q = e.target.value.trim()
        if (q.length < 2) return
        const items = await this.fetchJSON(`/api/lookup/abilities?q=${encodeURIComponent(q)}`)
        this.setDatalist(this.abilityOptionsTarget, items)
    }
    commitAbility(e){
        const opt = this.pickFromDatalist(this.abilityNameTarget, this.abilityOptionsTarget)
        this.abilityIdTarget.value = opt ? (opt.dataset.id || "") : ""
    }

    // --- items ---
    async searchItems(e){
        const q = e.target.value.trim()
        if (q.length < 2) return
        const items = await this.fetchJSON(`/api/lookup/items?q=${encodeURIComponent(q)}`)
        this.setDatalist(this.itemOptionsTarget, items)
    }
    commitItem(e){
        const opt = this.pickFromDatalist(this.itemNameTarget, this.itemOptionsTarget)
        this.itemIdTarget.value = opt ? (opt.dataset.id || "") : ""
    }

    // --- moves ---
    async searchMoves(e){
        const input = e.target
        const q = input.value.trim()
        if (q.length < 2) return

        // prefer learnset if available
        let items = (this.learnset || []).filter(m => m.name.toLowerCase().includes(q.toLowerCase()))
        if (items.length === 0) {
            // fallback to global search
            items = await this.fetchJSON(`/api/lookup/moves?q=${encodeURIComponent(q)}`)
            input.classList.add("illegal-hint")
        } else {
            input.classList.remove("illegal-hint")
        }

        const optionsEl = input.nextElementSibling
        optionsEl.innerHTML = items.map(i => `<option data-id="${i.id}" value="${i.name}"></option>`).join("")
    }

    commitMove(e){
        const input = e.target
        const optionsEl = input.nextElementSibling
        const opt = (() => {
            const val = input.value.toLowerCase()
            return Array.from(optionsEl.options).find(o => o.value.toLowerCase() === val) || null
        })()

        const row = input.closest(".move-row")
        const hidden = row.querySelector("input[type='hidden'][name$='[move_id]']")
        if (hidden) hidden.value = opt ? (opt.dataset.id || "") : ""

        // simple inline legality hint
        if (opt && (this.learnset || []).some(m => String(m.id) === String(opt.dataset.id))) {
            input.classList.remove("illegal-hint")
        } else {
            input.classList.add("illegal-hint")
        }
    }
}
