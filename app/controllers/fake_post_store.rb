# In-memory post store used only for tests in this TDD phase.
module FakePostStore
  Post = Struct.new(:title, :species, keyword_init: true)

  def self.reset!
    @posts = []
  end

  def self.add(title:, species: nil)
    (@posts ||= []) << Post.new(title: title, species: species)
  end

  def self.all
    @posts || []
  end
end
