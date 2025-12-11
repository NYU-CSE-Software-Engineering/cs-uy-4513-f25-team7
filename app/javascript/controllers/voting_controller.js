import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { postId: Number }
  static targets = ["score"]

  upvote(event) {
    event.preventDefault()
    this.vote(event, 1)
  }

  downvote(event) {
    event.preventDefault()
    this.vote(event, -1)
  }

  vote(event, value) {
    const form = event.target.closest('form')
    if (!form) return

    // In test mode, let the form submit normally
    if (form.dataset.local === 'true' || form.hasAttribute('data-local')) {
      form.submit()
      return
    }

    // In production, use AJAX
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) {
      // Fallback to form submission if CSRF token not found
      form.submit()
      return
    }

    fetch(form.action, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url
      } else {
        return response.json()
      }
    })
    .then(data => {
      if (data && data.score !== undefined) {
        this.updateScore(data.score)
      }
    })
    .catch(error => {
      console.error('Vote error:', error)
      // Fallback to form submission
      form.submit()
    })
  }

  updateScore(newScore) {
    if (this.hasScoreTarget) {
      this.scoreTarget.textContent = newScore
      // Add a brief animation
      this.scoreTarget.style.transform = 'scale(1.2)'
      setTimeout(() => {
        this.scoreTarget.style.transform = 'scale(1)'
      }, 200)
    }
  }
}

