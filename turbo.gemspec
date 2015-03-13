Gem::Specification.new do |s|
    s.name        = "turbogenerator"
    s.version     = "0.4.0"
    s.date        = "2015-03-12"
    s.summary     = "turbo is a curl wrapper for make test based on HTTP more easier"
    s.description = "turbo is a curl wrapper for make test based on HTTP more easier"
    s.authors     = ["Juntao Qiu", "Jia Wei", "Shen Tong", "Yan Yu", "Yang Mengmeng"]
    s.email       = "juntao.qiu@gmail.com"
    s.files       = Dir.glob("{bin,lib}/**/*")
    s.add_runtime_dependency 'thor', '>=0.18.1'
    s.add_runtime_dependency 'term-ansicolor', '>=1.3.0'
    s.executables << "turbo"
    s.homepage    = "https://github.com/abruzzi/turbo"
    s.license     = "MIT"
end
