# Desafio WeCast

Projeto de aplicativo IOS nativo em relação ao desafio proposto pela WeCast.

## Features

- Download de posts do Feed RSS do podcast [Matando Robos Gigantes](http://feeds.feedburner.com/podcastmrg)
- Posts ordenados na primeira tela com opção de fazer o download do episódios
- Ao fazer swipe down um campo de busca aparece e é possível realizar buscas pelo episódio desejado
- Ao clicar em um episódio é chamado uma segunda tela e imediatamente inicia a reprodução do mesmo. 
- Se o episódio já foi baixado anteriormente o player executa o arquivo de áudio local, caso contrario realiza o streaming
- Na segunda dela do player, existem opções de pausar, saltar ou retroceder e avançar 30 segundos ou recuar 10 segundos do podcast
- Existe um slider que indica a posição atual do tempo de reprodução que pode ser ajustado tanto para streaming ou reprodução local.

Preview do App em vídeo: preview.mov 

## Dependencies

O projeto tem 3 dependências de terceiros:
1. [FeedKit](https://github.com/nmdias/FeedKit)
	- Um analisador de RSS, Atom e JSON Feed escrito em Swift 
2. [Kingfisher](https://github.com/onevcat/Kingfisher)
	- O Kingfisher é uma biblioteca poderosa, pura e rápida para baixar e armazenar em cache imagens da web. Ele oferece uma alternativa pura-Swift em novos aplicativos
3. [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)
	- Uma coleção de animações de carregamento

## Installing

1. Instalar o [Cocoapods](https://cocoapods.org/#install)  se for necessário.

	sudo gem install cocoapods

2. Extraia o diretório e abra o terminal na raiz do projeto

3. Execute o comando para instalar as dependências presentes no Podfile na raiz do projeto

	pod install

4. Abrir em uma versão recente do Xcode do arquivo "wecast_player.xcworkspace”

5. Compilar e rodar o projeto (cmd + R)

## Plataforma de desenvolvimento usada
- IOS 11.0
- Xcode 10.1
- Swift 4
- Simulator iPhone XR 

## Autor

- **Thomás Marques Brandão Reis**  - [Email](thomas.marquesbr@gmail.com) [Github](https://github.com/thomasmbr) [Site](https://thomasmarques.com.br) [Linkedin](https://www.linkedin.com/in/thom%C3%A1s-reis-334391a0/)[Whatsapp](whatsapp://send?phone=5532991268634) [Facebook](https://www.facebook.com/thomas.marquesbr) [Twitter](https://twitter.com/thomas_mbr)

## Agradecimentos

- **WeCast Team**
