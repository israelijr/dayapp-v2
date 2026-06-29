/**
 * Script do Google Apps Script para criar os formulários do Roteiro de Testes do DayApp.
 * 
 * Instruções de Uso:
 * 1. Acesse https://script.google.com/ com sua conta Google.
 * 2. Clique em "Novo projeto".
 * 3. Cole todo o código deste arquivo no editor de código (substituindo qualquer código existente).
 * 4. Salve o projeto (ícone de disquete ou Ctrl+S).
 * 5. Selecione a função `criarFormulariosDeTeste` na barra de ferramentas superior e clique em "Executar".
 * 6. Conceda as permissões necessárias para o script acessar e criar arquivos no seu Google Drive.
 * 7. Visualize os links gerados no "Registro de execução" (Execution Log).
 */

function criarFormulariosDeTeste() {
  Logger.log('Iniciando a criação dos formulários de teste...');
  
  // Cabeçalho compartilhado entre os formulários
  const descricaoCabecalhoBase = 
    'Versão do app: 1.1.0 | Plataforma: Android\n' +
    'Dedique de 30 a 60 minutos por dia. Registre o resultado de cada caso de teste.\n\n' +
    'Legenda:\n' +
    '✅ Passou – funcionou como esperado\n' +
    '❌ Falhou – comportamento incorreto\n' +
    '⚠️ Inconclusivo ou comportamento estranho';

  // Opções de resposta padrão para as perguntas de teste
  const opcoesResposta = ['✅ Passou', '❌ Falhou', '⚠️ Inconclusivo'];

  // ==================== FORMULÁRIO PARTE 1 (DIAS 1 A 7) ====================
  const dadosForm1 = {
    titulo: 'Roteiro de Testes – DayApp (Parte 1)',
    descricao: descricaoCabecalhoBase,
    secoes: [
      {
        titulo: 'Dia 1 – Instalação, Conta e Primeiro Acesso',
        perguntas: [
          { acao: 'Instale o app e abra pela primeira vez', expectativa: 'Tela de splash animada, depois tela de login' },
          { acao: 'Aguarde a tela de login carregar completamente', expectativa: 'Sem travamento, elementos carregados' },
          { acao: 'Toque em "Criar conta"', expectativa: 'Navega para tela de criação de conta' },
          { acao: 'Tente salvar sem preencher nenhum campo', expectativa: 'Validação exige preenchimento dos campos obrigatórios' },
          { acao: 'Preencha um e-mail inválido (sem "@")', expectativa: 'Mensagem de erro de formato de e-mail' },
          { acao: 'Preencha com senha muito curta', expectativa: 'Mensagem de erro de tamanho mínimo' },
          { acao: 'Preencha nome, e-mail válido e senha forte → confirme', expectativa: 'Conta criada; entra no app ou avança para complemento' },
          { acao: 'Complete o perfil inicial (nome/fotos se solicitado)', expectativa: 'Etapa de complemento concluída, chega à tela principal' },
          { acao: 'Faça logout → tente login com senha errada', expectativa: 'Mensagem de erro de credenciais' },
          { acao: 'Faça login com e-mail e senha corretos', expectativa: 'Entra na tela principal (Home)' },
          { acao: 'Feche e reabra o app sem fazer logout', expectativa: 'Mantém a sessão, vai direto para Home' }
        ]
      },
      {
        titulo: 'Dia 2 – Segurança',
        perguntas: [
          { acao: 'Configurações → PIN → Ativar PIN', expectativa: 'Solicita digitação de PIN' },
          { acao: 'Digite o mesmo PIN duas vezes e confirme', expectativa: 'PIN salvo com sucesso' },
          { acao: 'Configurações → Segurança → Informar seu e-mail', expectativa: 'Salva e-mail para recuperação de PIN' },
          { acao: 'Configurações → Biometria → Ativar', expectativa: 'Solicita e-mail/senha para vincular biometria' },
          { acao: 'Autentique com sucesso', expectativa: 'Desbloqueio imediato' },
          { acao: 'Configurações → Bloqueio em Segundo Plano → selecione "Imediato"', expectativa: 'App deve bloquear assim que for minimizado' },
          { acao: 'Minimize o app, aguarde 1s e reabra', expectativa: 'Tela de bloqueio exibida' },
          { acao: 'Altere timeout para "30 segundos" e minimize', expectativa: 'Se reabrir em <30s, entra direto; se >30s bloqueia' }
        ]
      },
      {
        titulo: 'Dia 3 – Criar Histórias: Campos Básicos',
        perguntas: [
          { acao: 'Toque no botão "+" na Home', expectativa: 'Abre tela de criação com teclado focado no título' },
          { acao: 'Toque no seletor de humor e energia', expectativa: 'Seleção fluida com feedback visual das cores/níveis' },
          { acao: 'Toque no botão de Emoji na barra inferior', expectativa: 'Abre modal de seleção de emojis categorizados' },
          { acao: 'Selecione um emoji', expectativa: 'Emoji aparece como um chip removível na história' },
          { acao: 'No campo de tags, digite e confirme com vírgula', expectativa: 'Tag criada como chip azul' },
          { acao: 'Adicione uma tag que já existe', expectativa: 'Sugestão aparece abaixo do campo; selecionável' }
        ]
      },
      {
        titulo: 'Dia 4 – Criar Histórias: Editor Rico e Lembretes',
        perguntas: [
          { acao: 'No campo de descrição, use a barra de ferramentas', expectativa: 'Negrito, Itálico e Listas aplicam-se em tempo real' },
          { acao: 'Toque no botão "Expandir" (canto sup. dir. do campo)', expectativa: 'Abre editor em tela cheia com animação de escala' },
          { acao: 'Digite sem capitalizar após um ponto final', expectativa: 'Corretor automático capitaliza após "." ou "?" ou "!"' },
          { acao: 'Salve a história com uma data futura (ex: +1 hora)', expectativa: 'Modal pergunta se deseja criar lembrete' },
          { acao: 'Configure lembrete para 5 minutos antes', expectativa: 'Notificação agendada' }
        ]
      },
      {
        titulo: 'Dia 5 – Mídia: Fotos',
        perguntas: [
          { acao: 'Adicione 3 fotos da galeria de uma vez', expectativa: 'Carregamento múltiplo funciona; fotos em miniaturas' },
          { acao: 'Tire uma foto com a câmera', expectativa: 'Foto adicionada à lista' },
          { acao: 'Salve a história e verifique na Home', expectativa: 'Card mostra grid/preview das fotos' },
          { acao: 'Toque em uma foto no modo de edição/view', expectativa: 'Abre visualizador em tela cheia (fundo escuro)' },
          { acao: 'Faça gesto de pinça (pinch-to-zoom)', expectativa: 'Zoom funciona sem distorção' }
        ]
      },
      {
        titulo: 'Dia 6 – Mídia: Áudio e Vídeo',
        perguntas: [
          { acao: 'Toque no ícone de Microfone', expectativa: 'Abre modal de gravação' },
          { acao: 'Grave por 5 segundos e pare', expectativa: 'Áudio aparece como ícone compacto com tempo de duração' },
          { acao: 'Adicione um vídeo da galeria', expectativa: 'Miniatura (thumbnail) gerada automaticamente' },
          { acao: 'Toque no ícone do vídeo', expectativa: 'Abre player integrado com controles de reprodução' }
        ]
      },
      {
        titulo: 'Dia 7 – Criação em Massa',
        perguntas: [
          { acao: 'Crie pelo menos 15-20 histórias distribuídas nos últimos 6 meses (usando pelo menos 5 tags diferentes, variando humor e adicionando fotos)', expectativa: 'Histórias salvas e exibidas perfeitamente na Home' }
        ]
      }
    ]
  };

  // ==================== FORMULÁRIO PARTE 2 (DIAS 8 A 14) ====================
  const dadosForm2 = {
    titulo: 'Roteiro de Testes – DayApp (Parte 2)',
    descricao: descricaoCabecalhoBase,
    secoes: [
      {
        titulo: 'Dia 8 – Home Feed, Preview e Swipes Rápidos',
        perguntas: [
          { acao: 'Observe o topo da Home', expectativa: 'Banner com saudação (Bom dia/tarde/noite) e seu nome' },
          { acao: 'Toque no Switch "Mostrar Tudo" no topo', expectativa: 'Inclui/esconde histórias arquivadas no feed principal' },
          { acao: 'Deslize um card para a DIREITA (Início)', expectativa: 'Aparece botão "Arquivar"; ao clicar, história arquiva' },
          { acao: 'Deslize um card para a ESQUERDA (Fim)', expectativa: 'Aparece botão "Agrupar"; ao clicar, abre o seletor' },
          { acao: 'No seletor, escolha um grupo ou "Criar Novo Grupo"', expectativa: 'História é movida para o grupo e sai da Home' },
          { acao: 'Toque duas vezes rápido (Double Tap) em um card', expectativa: 'Abre "Preview de História" (tela limpa e elegante)' },
          { acao: 'No Preview, toque no ícone de Compartilhar (topo dir.)', expectativa: 'Abre diálogo de geração de imagem para redes sociais' }
        ]
      },
      {
        titulo: 'Dia 9 – Calendário e Navegação Temporal',
        perguntas: [
          { acao: 'Acesse o Calendário (via ícone na Home)', expectativa: 'Calendário do mês atual com pontos nos dias ocupados' },
          { acao: 'Toque em um dia com ponto', expectativa: 'Lista histórias daquele dia abaixo do calendário' },
          { acao: 'Navegue entre meses deslizando', expectativa: 'Transição suave entre meses' }
        ]
      },
      {
        titulo: 'Dia 10 – Coleções: Grupos e Arquivamento',
        perguntas: [
          { acao: 'Toque na aba "Coleções" no menu inferior', expectativa: 'Abre tela de Coleções com abas: Capítulos e Grupos' },
          { acao: 'Toque na sub-aba "Grupos"', expectativa: 'Exibe lista/grid de grupos criados pelo usuário' },
          { acao: 'Toque em um grupo (ex: "Pessoal")', expectativa: 'Abre lista de histórias associadas àquele grupo' },
          { acao: 'No card da história, deslize para a DIREITA', expectativa: 'Opção "Arquivar" aparece; move para arquivados' },
          { acao: 'No card da história, deslize para a ESQUERDA', expectativa: 'Opção "Desagrupar" aparece; história sai desse grupo' },
          { acao: 'No final da lista de grupos, localize "Arquivados"', expectativa: 'Círculo especial que abre a lista de arquivadas' }
        ]
      },
      {
        titulo: 'Dia 11 – Coleções: Capítulos e Narrativa',
        perguntas: [
          { acao: 'Na aba Coleções, toque na sub-aba "Capítulos"', expectativa: 'Exibe lista de capítulos existentes e sugestões' },
          { acao: 'Localize o banner de "Sugestão Automática"', expectativa: 'Aparece se houver histórias suficientes em um período' },
          { acao: 'Toque no botão de "+" ou "Criar Manual"', expectativa: 'Inicia fluxo de criação manual' },
          { acao: 'Tente criar capítulo com menos de 3 histórias', expectativa: 'App informa que o mínimo são 3 entradas para um capítulo' },
          { acao: 'Toque em um capítulo criado', expectativa: 'Abre detalhes (datas, barra de humor médio, resumos)' },
          { acao: 'Toque no ícone de "Livro" (Abrir modo leitura)', expectativa: 'Inicia experiência de narrativa imersiva' }
        ]
      },
      {
        titulo: 'Dia 12 – Pesquisa e Insights no Feed',
        perguntas: [
          { acao: 'Toque na aba "Pesquisar" no menu inferior', expectativa: 'Abre tela de busca global dedicada' },
          { acao: 'Selecione o filtro "Tag" e escolha uma', expectativa: 'Filtra histórias instantaneamente' },
          { acao: 'No Feed da Home, localize os Cards de Insight', expectativa: 'Cards aparecem entre as histórias' },
          { acao: 'Toque duas vezes no gráfico', expectativa: 'Atualiza os dados do insight (refresh manual)' }
        ]
      },
      {
        titulo: 'Dia 13 – Lixeira e Backup',
        perguntas: [
          { acao: 'Exclua uma história → Vá em Config. → Lixeira', expectativa: 'História está lá; mostra dias restantes para expirar' },
          { acao: 'Restaure a história', expectativa: 'Volta para a data original no Feed' },
          { acao: 'Configurações → Backup → Gerenciar Backup Completo', expectativa: 'Inicia compactação de fotos, áudios e vídeos' },
          { acao: 'Gere o arquivo .zip e compartilhe para o Drive/E-mail', expectativa: 'Arquivo gerado com sucesso; contém pastas de mídia' }
        ]
      },
      {
        titulo: 'Dia 14 – Configurações, Temas e Idiomas',
        perguntas: [
          { acao: 'Configurações → Tema → Escolher Esquema', expectativa: 'Opções: Relva, Outono, Céu, Sunset, Midnight Galaxy' },
          { acao: 'Selecione um esquema e altere entre Claro/Escuro', expectativa: 'App assume as novas cores em todas as telas' },
          { acao: 'Configurações → Idioma → Italiano / Francês', expectativa: 'Interface traduzida completamente' },
          { acao: 'Toque em "Restrições de Segundo Plano" (Notific.)', expectativa: 'Abre tela informativa sobre otimização de bateria' }
        ]
      },
      {
        titulo: 'Checklist Final de Qualidade',
        perguntas: [
          { acao: 'O app mantém a fluidez ao rolar o feed com muitas fotos', expectativa: 'Atende aos critérios de performance esperados' },
          { acao: 'O "Double Tap" no card de história é consistente e rápido', expectativa: 'Atende aos critérios de usabilidade esperados' },
          { acao: 'A restauração de backup em um novo dispositivo recupera 100% das fotos', expectativa: 'Atende aos critérios de segurança e persistência de dados' },
          { acao: 'O bloqueio "Imediato" não falha ao alternar entre apps', expectativa: 'Atende aos critérios de proteção de privacidade' }
        ]
      }
    ]
  };

  // Criar formulário 1
  const form1 = criarForm(dadosForm1, opcoesResposta);
  Logger.log('--------------------------------------------------');
  Logger.log('FORMULÁRIO PARTE 1 CRIADO COM SUCESSO!');
  Logger.log('Link de Edição: ' + form1.getEditUrl());
  Logger.log('Link para Responder: ' + form1.getPublishedUrl());
  Logger.log('--------------------------------------------------');

  // Criar formulário 2
  const form2 = criarForm(dadosForm2, opcoesResposta);
  Logger.log('--------------------------------------------------');
  Logger.log('FORMULÁRIO PARTE 2 CRIADO COM SUCESSO!');
  Logger.log('Link de Edição: ' + form2.getEditUrl());
  Logger.log('Link para Responder: ' + form2.getPublishedUrl());
  Logger.log('--------------------------------------------------');

  Logger.log('Processo finalizado com sucesso!');
}

/**
 * Função auxiliar para gerar um formulário completo com base nas configurações passadas.
 */
function criarForm(dados, opcoesResposta) {
  // Cria o formulário e define o título
  const form = FormApp.create(dados.titulo);
  form.setTitle(dados.titulo);
  form.setDescription(dados.descricao);

  // Adiciona as perguntas do cabeçalho inicial (Seção 1)
  const nomeItem = form.addTextItem();
  nomeItem.setTitle('Nome do Testador');
  nomeItem.setRequired(true);

  const dispositivoItem = form.addTextItem();
  dispositivoItem.setTitle('Modelo do Dispositivo Android (ex: Galaxy S23, Moto G54)');
  dispositivoItem.setRequired(true);

  // Itera sobre as seções de dias do roteiro de testes
  dados.secoes.forEach((secao) => {
    // Cria uma quebra de seção (página)
    const pageBreak = form.addPageBreakItem();
    pageBreak.setTitle(secao.titulo);

    // Adiciona as perguntas dessa seção
    secao.perguntas.forEach((pergunta) => {
      // Pergunta de múltipla escolha para o resultado do teste
      const mcItem = form.addMultipleChoiceItem();
      
      // Concatena a Ação e o Resultado Esperado (Expectativa)
      const tituloPergunta = 
        pergunta.acao + '\n' +
        'Expectativa: ' + pergunta.expectativa;
      
      mcItem.setTitle(tituloPergunta);
      
      // Define as opções (✅ Passou, ❌ Falhou, ⚠️ Inconclusivo)
      const choices = opcoesResposta.map(opcao => mcItem.createChoice(opcao));
      mcItem.setChoices(choices);
      mcItem.setRequired(false); // Não obrigatória para que o testador possa preencher aos poucos

      // Campo de observação não obrigatório logo em seguida
      const obsItem = form.addParagraphTextItem();
      obsItem.setTitle('Observação');
      obsItem.setRequired(false);
    });
  });

  return form;
}
