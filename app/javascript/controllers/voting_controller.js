import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["score", "upvoteBtn", "downvoteBtn"]
  
  upvote(event) {
    event.preventDefault()
    this.vote(event.target.closest('form').action, 1)
  }
  
  downvote(event) {
    event.preventDefault()
    this.vote(event.target.closest('form').action, -1)
  }
  
  vote(url, value) {
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.scoreTargets.forEach(target => {
          if (target.dataset.postId === this.data.get('post-id')) {
            target.textContent = data.vote_score
          }
        })
        
        this.updateButtonStates(data.user_vote)
        this.showMessage(data.message)
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showMessage('Error voting. Please try again.')
    })
  }
  
  updateButtonStates(userVote) {
    this.upvoteBtnTargets.forEach(btn => {
      btn.style.backgroundColor = ''
      btn.style.color = '#ff4500'
    })
    this.downvoteBtnTargets.forEach(btn => {
      btn.style.backgroundColor = ''
      btn.style.color = '#7193ff'
    })
    
    if (userVote === 1) {
      this.upvoteBtnTargets.forEach(btn => {
        btn.style.backgroundColor = '#ff4500'
        btn.style.color = 'white'
      })
    } else if (userVote === -1) {
      this.downvoteBtnTargets.forEach(btn => {
        btn.style.backgroundColor = '#7193ff'
        btn.style.color = 'white'
      })
    }
  }
  
  showMessage(message) {
    const messageEl = document.createElement('div')
    messageEl.textContent = message
    messageEl.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: #0079d3;
      color: white;
      padding: 10px 20px;
      border-radius: 4px;
      z-index: 1000;
      font-size: 14px;
    `
    
    document.body.appendChild(messageEl)
    
    setTimeout(() => {
      messageEl.remove()
    }, 3000)
  }
}
