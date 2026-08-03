require "json"
require "cgi"

puts "Criando usuário admin..."
admin = User.find_or_create_by!(email: "livia@prescricao.com") do |u|
  u.name = "Livia"
  u.password = "livia@123456"
  u.password_confirmation = "livia@123456"
  u.role = "admin"
end
admin.update!(role: "admin", name: "Livia") if admin.name.blank?
puts "Admin criado: livia@prescricao.com / livia@123456"

puts "Importando prescrições..."
data_file = Rails.root.join("db", "prescricoes_seed.json").to_s

unless File.exist?(data_file)
  puts "AVISO: Arquivo #{data_file} não encontrado. Pulando importação de prescrições."
else
  data = JSON.parse(File.read(data_file))
  total = data.size
  count = 0

  data.each_with_index do |(raw_title, raw_content), index|
    title = raw_title.gsub("_", " ")
    content = CGI.unescapeHTML(raw_content.to_s)
    category = title.split(/\s*[-–\/]\s*/).first.to_s.strip

    Prescription.find_or_create_by!(title: title) do |p|
      p.content = content
      p.category = category.presence || "Geral"
      p.position = index + 1
    end

    count += 1
    print "\r  #{count}/#{total} prescrições..." if (count % 100).zero?
  end

  puts "\n#{Prescription.count} prescrições importadas com sucesso!"
end
