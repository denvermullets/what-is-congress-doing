class OllamaIngestBill < ApplicationJob
  def perform(bill:)
    puts "******** starting Bill Job #{bill.title}"
    Ollama::Generate.call(bill:)
    puts '******** finished'
  end
end
