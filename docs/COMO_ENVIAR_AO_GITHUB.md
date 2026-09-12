# Como enviar este entregável ao seu GitHub

Repositório de destino: `https://github.com/Keth393/tech_challenge_fase3`.

## Pelo navegador do celular ou computador

1. Baixe e descompacte o ZIP final.
2. Abra o seu repositório `Keth393/tech_challenge_fase3`.
3. Entre na aba **Code**.
4. Toque em **Add file** e depois em **Upload files**.
5. Envie a pasta `entregavel_3` completa.
6. No campo de mensagem, escreva `Adiciona entregável 3 completo`.
7. Escolha criar uma nova branch e abrir um Pull Request, se essa opção aparecer. Caso contrário, confirme o commit na sua cópia.
8. Verifique se os quatro arquivos `.ipynb` aparecem na pasta `entregavel_3/notebooks`.

## Pelo Git em um computador

```bash
git clone https://github.com/Keth393/tech_challenge_fase3.git
cd tech_challenge_fase3
git checkout -b entregavel-3-completo
# copie a pasta entregavel_3 para este diretório
git add entregavel_3
git commit -m "Adiciona entregável 3 completo"
git push -u origin entregavel-3-completo
```

Depois, abra o Pull Request exibido pelo GitHub e revise os arquivos antes de mesclar.

## Verificação rápida após o envio

- existem quatro notebooks numerados de `01` a `04`;
- existem seis SQLs em `athena/transformacoes`;
- existem quatro arquivos Python em `glue` (um consolidado e três originais);
- existem os documentos de guia, metodologia, revisão, conformidade e checklist;
- nenhuma credencial AWS foi enviada.

Não envie alterações ao repositório original de Gabrielle. Use somente o fork/repositório da conta `Keth393`.
