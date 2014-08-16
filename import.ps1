ruby -rubygems -e 'require "jekyll-import";
 JekyllImport::Importers::WordPress.run({
  "dbname" => "blog_cyberkinetx",
   "user"   => "root",
   "password" => "MyNewPass",
   "host"    => "partizan-server",
   "table_prefix" => "wp_angt54_",
   "comments" => true
 })'
