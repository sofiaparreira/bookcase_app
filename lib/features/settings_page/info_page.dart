// Tela feita por: Maria Luiza Bertolino Matos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef InfoSection = ({String title, String body});

class InfoPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<InfoSection> sections;

  const InfoPage({
    super.key,
    required this.title,
    required this.icon,
    required this.intro,
    this.sections = const [],
  });

  const InfoPage.about({super.key})
    : title = 'Sobre o aplicativo',
      icon = LucideIcons.bookOpen,
      intro =
          'O Página é um aplicativo para quem ama livros. Organize sua '
          'estante, acompanhe o progresso das suas leituras e descubra novos '
          'títulos para ler.',
      sections = const [
        (
          title: 'Sua estante',
          body:
              'Separe seus livros entre quero ler, lendo e lidos, e '
              'encontre qualquer um deles com facilidade.',
        ),
        (
          title: 'Metas de leitura',
          body:
              'Defina metas, registre as páginas lidas e acompanhe sua '
              'evolução ao longo do tempo.',
        ),
        (
          title: 'Lista de compras',
          body:
              'Guarde os livros que você deseja comprar e marque quando '
              'eles chegarem à sua estante.',
        ),
      ];

  const InfoPage.privacy({super.key})
    : title = 'Política de Privacidade',
      icon = LucideIcons.lock,
      intro =
          'Sua privacidade é importante para nós. Esta política explica, de '
          'forma resumida, como tratamos as suas informações.',
      sections = const [
        (
          title: 'Dados coletados',
          body:
              'Coletamos apenas o necessário para o funcionamento do app: '
              'nome, e-mail e as informações sobre os livros que você '
              'cadastra.',
        ),
        (
          title: 'Uso das informações',
          body:
              'Seus dados são usados somente para oferecer e melhorar a sua '
              'experiência no app. Não vendemos nem compartilhamos suas '
              'informações com terceiros.',
        ),
        (
          title: 'Seus direitos',
          body:
              'Você pode solicitar a alteração ou a exclusão dos seus dados '
              'a qualquer momento.',
        ),
      ];

  const InfoPage.terms({super.key})
    : title = 'Termos de Uso',
      icon = LucideIcons.fileText,
      intro =
          'Ao usar o Página, você concorda com os termos abaixo. Leia com '
          'atenção.',
      sections = const [
        (
          title: 'Uso da conta',
          body:
              'Você é responsável por manter sua senha em segurança e por '
              'todas as atividades realizadas na sua conta.',
        ),
        (
          title: 'Conteúdo',
          body:
              'As informações sobre livros são fornecidas por fontes '
              'públicas e podem conter imprecisões.',
        ),
        (
          title: 'Alterações',
          body:
              'Estes termos podem ser atualizados periodicamente. O uso '
              'contínuo do app indica que você concorda com as mudanças.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: title,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            Text(
              intro,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            for (final section in sections)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      section.body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
