ECD Converter
=============

Descrever o projeto aqui!!!

[Board de Planejamento no Trello] (https://trello.com/b/4ivRtH5D/ecf-ecd)

1. Instale o Bundler (se ainda não estiver instalado):

  ```bash
  $ gem install bundler
  ```

2.  Resolva as depêndencias:

  ```bash
  $ bundle install
  ```

3. Execute os testes:

  ```bash
  $ rake spec
  ```

4. Happy Coding!!! :-)

5. Instrucões de uso:

  ```bash
  $ chmod +x bin/ecd_converter
  ```
  ```bash
  $ ./bin/ecd_converter <nome do arquivo de entrada> [<nome do arquivo de saida>]
  ```

  O parâmetro <nome do arquivo de saida> é opcional (Caso omitido, o valor ecd_convertido.txt sera usado como padrao).
