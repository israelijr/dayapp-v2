# Guia de Referência: Correções de Build para Release (Play Store)

Este documento registra as soluções aplicadas para resolver erros críticos encontrados durante o lançamento da versão 1.0.2 no Play Console.

---

## 1. Erro: `Could not find 'libflutter.so'`
**Sintoma:** O app fecha imediatamente após a instalação via Play Store com o erro `java.lang.RuntimeException: java.util.concurrent.ExecutionException: T1.b: Could not find 'libflutter.so'`.

### Causa:
Incompatibilidade entre as novas versões do Android Gradle Plugin (AGP 8.x) e configurações legadas de empacotamento. O uso de `extractNativeLibs="true"` e `useLegacyPackaging = true` estava impedindo que as bibliotecas nativas (ABIs) fossem incluídas corretamente no App Bundle (.aab).

### Solução:
- **AndroidManifest.xml:** Removido o atributo `android:extractNativeLibs="true"` da tag `<application>`.
- **build.gradle.kts (app):** Removido o bloco `jniLibs { useLegacyPackaging = true }` dentro de `packaging`.
- **Configuração Atual:** O Android agora carrega as bibliotecas nativas diretamente do APK/Bundle sem necessidade de extração, o que é o padrão recomendado para Google Play.

---

## 2. Erro: `MissingPluginException (flutter_secure_storage)`
**Sintoma:** O app inicia, mas exibe uma tela de erro antes da Splash ou ao tentar acessar dados protegidos, informando que o método `read` não foi encontrado no canal do plugin.

### Causa:
O otimizador de código **R8 (ProGuard)** estava identificando o código nativo do plugin como "não utilizado" em builds de Release e removendo-o (minificação). Além disso, o plugin estava apenas em `dependency_overrides`, o que dificultava o registro automático.

### Solução:
1. **pubspec.yaml:** Mover `flutter_secure_storage` para a seção principal de `dependencies`.
2. **proguard-rules.pro:** Adicionar regras explícitas para manter as classes do plugin e da biblioteca de segurança do Android.

**Regras Essenciais do ProGuard:**
```proguard
# Flutter Secure Storage - Manter classes e interfaces
-keep class com.it_nomads.** { *; }
-keep interface com.it_nomads.** { *; }
-keep class plugins.it_nomads.** { *; }
-keep class **.FlutterSecureStoragePlugin { *; }
-dontwarn com.it_nomads.**

# Biblioteca de Criptografia (usada pelo plugin no Android 10+)
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**
```

---

## 3. Erro: `MissingPluginException` na Inicialização (Race Condition)
**Sintoma:** Mesmo com ProGuard configurado, o app falha na Play Store com `No implementation found for method read`.

### Causa:
Chamada de plugins nativos (como `FlutterSecureStorage` ou `InAppPurchase`) dentro do `void main()` antes da Engine do Android completar o registro dos plugins. Em produção (Play Store), o carregamento é mais lento que em Debug.

### Solução:
- **Remover** inicializações de plugins do `main()`.
- **Mover** a lógica de inicialização para o `_initializeApp()` dentro do primeiro widget (Splash).
- **Adicionar um delay** de segurança (ex: 500ms) para garantir que a Engine esteja pronta.

---

## 4. Erro: Faturamento (Billing) não detectado no Play Console
**Sintoma:** O Play Console não permite criar produtos in-app, alegando falta da biblioteca de faturamento.

### Causa:
O plugin `in_app_purchase` estava apenas em `dependency_overrides` ou a permissão de faturamento não foi explicitamente declarada/detectada.

### Solução:
- **pubspec.yaml:** Mover `in_app_purchase` para a seção principal de `dependencies`.
- **AndroidManifest.xml:** Adicionar explicitamente a permissão `<uses-permission android:name="com.android.vending.BILLING" />`.

---

## 5. Checklist Obrigatório para Novo Build de Release

Sempre que for gerar uma nova versão para o Play Store, siga estes passos na ordem:

1. **Incrementar Versão:** Atualize o `version` no `pubspec.yaml` (ex: `1.0.3+9`).
2. **Limpeza Profunda:**
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Gerar Bundle:**
   ```bash
   flutter build appbundle --release
   ```
4. **Teste de Sanidade (Bundletool):**
   Antes de subir na loja, use o `bundletool` para instalar o `.aab` em um dispositivo real e verificar se ele passa da Splash Screen.
   ```bash
   java -jar bundletool.jar build-apks --bundle=app-release.aab --output=app.apks --mode=universal
   java -jar bundletool.jar install-apks --apks=app.apks
   ```

---
*Documentação criada em Junho de 2026 para referência futura.*
