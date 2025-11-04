// app/javascript/controllers/slot_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "speciesId","speciesName","speciesOptions",
        "abilityId","abilityName","abilityOptions",
        "itemId","itemName","itemOptions",
        "moveId","moveName"
    ]
    static values = { position: Number }

    // --- helpers ---
    async fetchJSON(url) {
        const res = await fetch(url)
        if (!res.ok) return []
        return await res.json()
    }
    setDatalist(optionsEl, items) {
        // items: [{id, name}]  -> <option data-id="id" value="name">
        optionsEl.innerHTML = items.map(i => `<option data-id="${i.id}" value="${i.name}"></option>`).join("")
    }
    pickFromDatalist(inputEl, optionsEl) {
        const val = inputEl.value.toLowerCase()
        const opt = Array.from(optionsEl.options).find(o => o.value.toLowerCase() === val)
        return opt ? opt.dataset.id : null
    }

    // --- species ---
    async searchSpecies(e){
        const q = e.target.value.trim()
        if (q.length < 2) return
        const items = await this.fetchJSON(`/api/lookup/species?q=${encodeURIComponent(q)}`)
        this.setDatalist(this.speciesOptionsTarget, items)
    }
    async commitSpecies(e){
        const id = this.pickFromDatalist(this.speciesNameTarget, this.speciesOptionsTarget)
        if (id) {
            this.speciesIdTarget.value = id
            // Preload learnset for SV to power move legality & suggestions
            this.learnset = await this.fetchJSON(`/api/lookup/learnset?species_id=${id}&format=sv`)
        } else {
            this.speciesIdTarget.value = ""
            this.learnset = []
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
        const optionsEl = this.abilityOptionsTarget
        const id = this.pickFromDatalist(this.abilityNameTarget, optionsEl)
        this.abilityIdTarget.value = id || ""
    }

    // --- items ---
    async searchItems(e){
        const q = e.target.value.trim()
        if (q.length < 2) return
        const items = await this.fetchJSON(`/api/lookup/items?q=${encodeURIComponent(q)}`)
        this.setDatalist(this.itemOptionsTarget, items)
    }
    commitItem(e){
        const id = this.pickFromDatalist(this.itemNameTarget, this.itemOptionsTarget)
        this.itemIdTarget.value = id || ""
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
            // you can add a CSS hint for "not in learnset" if you want
            input.classList.add("illegal-hint")
        } else {
            input.classList.remove("illegal-hint")
        }

        // find the datalist immediately following this input
        const optionsEl = input.nextElementSibling
        optionsEl.innerHTML = items.map(i => `<option data-id="${i.id}" value="${i.name}"></option>`).join("")
    }
    commitMove(e){
        const input = e.target
        const optionsEl = input.nextElementSibling
        const id = (() => {
            const val = input.value.toLowerCase()
            const opt = Array.from(optionsEl.options).find(o => o.value.toLowerCase() === val)
            return opt ? opt.dataset.id : null
        })()

        // find the matching hidden move_id for this row
        const row = input.closest(".move-row")
        const hidden = row.querySelector("input[type='hidden'][name$='[move_id]']")
        if (hidden) hidden.value = id || ""

        // simple inline legality hint
        if (id && (this.learnset || []).some(m => String(m.id) === String(id))) {
            input.classList.remove("illegal-hint")
        } else {
            input.classList.add("illegal-hint")
        }
    }
}
