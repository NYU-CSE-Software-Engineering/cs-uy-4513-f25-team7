import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"]

    search() {
        const query = this.inputTarget.value
        if (query.length < 2) return

        fetch(`/dex/species?term=${query}`)
            .then(r => r.json())
            .then(list => {
                console.log(list) // later build dropdown
            })
    }
}
