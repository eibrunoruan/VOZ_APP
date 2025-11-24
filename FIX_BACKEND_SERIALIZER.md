# 🔧 Fix para Erro 500 no Upload de Imagens

## 🚨 Problema Identificado

O backend Django está retornando **erro 500** quando o Flutter tenta criar uma denúncia com foto.

### Causa Raiz

No arquivo `/app/applications/denuncias/serializers.py`, linha 60, o código está tentando acessar `self.context['request'].user` sem verificar se o `request` existe:

```python
def validate(self, data):
    user = self.context['request'].user  # ❌ ERRO: Falha se request for None
    autor_convidado = data.get('autor_convidado')
    
    if user.is_authenticated:
        # ...
```

Quando o Flutter envia a requisição, o Django está processando sem um contexto de request válido, causando:

```
AttributeError: 'NoneType' object has no attribute 'user'
```

---

## ✅ Solução

Modificar o método `validate()` do serializer para verificar se o `request` existe antes de acessar `user`.

### Código Atual (ERRADO) - Linhas 59-67:

```python
def validate(self, data):
    user = self.context['request'].user
    autor_convidado = data.get('autor_convidado')

    if user.is_authenticated:
        if autor_convidado:
            raise serializers.ValidationError('Usuários autenticados não devem fornecer um nome de convidado.')
        return data
```

### Código Corrigido (CORRETO):

```python
def validate(self, data):
    request = self.context.get('request')
    user = request.user if request else None
    autor_convidado = data.get('autor_convidado')

    # Usuário autenticado: não pode fornecer nome de convidado
    if user and user.is_authenticated:
        if autor_convidado:
            raise serializers.ValidationError('Usuários autenticados não devem fornecer um nome de convidado.')
        return data
    
    # Usuário não autenticado (guest): DEVE fornecer nome de convidado
    if not user or not user.is_authenticated:
        if not autor_convidado:
            raise serializers.ValidationError('Usuários não autenticados devem fornecer um nome de convidado.')
        return data
    
    return data
```

---

## 📝 Passo a Passo para Aplicar o Fix

### 1. Conectar no VPS via SSH

```bash
ssh root@72.61.55.172
```

### 2. Acessar o container

```bash
docker exec -it voz-do-povo-api bash
```

### 3. Criar backup do arquivo

```bash
cp /app/applications/denuncias/serializers.py /app/applications/denuncias/serializers.py.backup
```

### 4. Editar o arquivo

```bash
nano /app/applications/denuncias/serializers.py
```

### 5. Localizar e modificar

Procure pela linha 59-60 (use `Ctrl+W` para buscar):

```
def validate(self, data):
```

**Substitua:**

```python
    def validate(self, data):
        user = self.context['request'].user
        autor_convidado = data.get('autor_convidado')

        if user.is_authenticated:
            if autor_convidado:
                raise serializers.ValidationError('Usuários autenticados não devem fornecer um nome de convidado.')
            return data

        # Se não autenticado, autor_convidado é obrigatório
        if not autor_convidado or autor_convidado.strip() == '':
            raise serializers.ValidationError('Usuários não autenticados devem fornecer um nome de convidado.')

        return data
```

**Por:**

```python
    def validate(self, data):
        request = self.context.get('request')
        user = request.user if request else None
        autor_convidado = data.get('autor_convidado')

        # Usuário autenticado: não pode fornecer nome de convidado
        if user and user.is_authenticated:
            if autor_convidado:
                raise serializers.ValidationError('Usuários autenticados não devem fornecer um nome de convidado.')
            return data
        
        # Usuário não autenticado (guest): DEVE fornecer nome de convidado
        if not user or not user.is_authenticated:
            if not autor_convidado or autor_convidado.strip() == '':
                raise serializers.ValidationError('Usuários não autenticados devem fornecer um nome de convidado.')
            return data
        
        return data
```

### 6. Salvar e sair

- Pressione `Ctrl+O` para salvar
- Pressione `Enter` para confirmar
- Pressione `Ctrl+X` para sair

### 7. Sair do container

```bash
exit
```

### 8. Reiniciar o container

```bash
docker restart voz-do-povo-api
```

### 9. Aguardar inicialização (10 segundos)

```bash
sleep 10
```

### 10. Verificar se está rodando

```bash
curl http://localhost:8000/api/health/
```

Deve retornar:
```json
{"status": "ok", "message": "API is running", "timestamp": ...}
```

---

## 🧪 Testar o Fix

### Teste 1: Diagnóstico Completo (EXECUTAR PRIMEIRO)

```bash
docker exec -it voz-do-povo-api python manage.py shell
```

Cole e execute este script de diagnóstico:

```python
import traceback
from applications.denuncias.serializers import DenunciaSerializer
from io import BytesIO
from PIL import Image
from django.core.files.uploadedfile import SimpleUploadedFile

print("="*60)
print("🔍 DIAGNÓSTICO COMPLETO - SUBMISSÃO GUEST")
print("="*60)

# Criar imagem de teste
img = Image.new('RGB', (100, 100), color='blue')
img_io = BytesIO()
img.save(img_io, format='JPEG')
img_io.seek(0)

uploaded_file = SimpleUploadedFile(
    "compressed_test.jpg",
    img_io.getvalue(),
    content_type="image/jpeg"
)

# Dados exatamente como Flutter envia (GUEST - sem autenticação)
data = {
    'titulo': 'Teste Guest',
    'descricao': 'Testando submissão de convidado',
    'categoria': 1,
    'cidade': 5275,
    'estado': 25,
    'latitude': -23.550520,
    'longitude': -46.633308,
    'jurisdicao': 'MUNICIPAL',
    'foto': uploaded_file,
    'autor_convidado': 'João Teste'  # CAMPO OBRIGATÓRIO PARA GUEST
}

print("\n📦 Dados enviados:")
for key, value in data.items():
    if key != 'foto':
        print(f"   {key}: {value}")
    else:
        print(f"   foto: <arquivo {uploaded_file.size} bytes>")

print("\n🔄 Testando validação do serializer...")

try:
    # Simular contexto sem autenticação (como Flutter envia)
    serializer = DenunciaSerializer(data=data, context={'request': None})
    
    print(f"\n✅ Serializer criado com sucesso")
    print(f"📊 is_valid(): {serializer.is_valid()}")
    
    if not serializer.is_valid():
        print(f"\n❌ ERROS DE VALIDAÇÃO:")
        for field, errors in serializer.errors.items():
            print(f"   {field}: {errors}")
    else:
        print(f"\n✅ Validação OK! Tentando salvar...")
        
        try:
            denuncia = serializer.save()
            print(f"\n🎉 SUCESSO TOTAL!")
            print(f"   ID: {denuncia.id}")
            print(f"   Título: {denuncia.titulo}")
            print(f"   Autor Convidado: {denuncia.autor_convidado}")
            print(f"   📸 Foto URL: {denuncia.foto.url}")
            
            if 'cloudinary' in denuncia.foto.url:
                print(f"\n✅✅✅ CLOUDINARY FUNCIONANDO!")
            else:
                print(f"\n⚠️ Foto não está no Cloudinary")
                
        except Exception as save_error:
            print(f"\n❌ ERRO AO SALVAR:")
            print(f"   Tipo: {type(save_error).__name__}")
            print(f"   Mensagem: {save_error}")
            print(f"\n🔍 Stack Trace Completo:")
            traceback.print_exc()
            
except Exception as e:
    print(f"\n❌ ERRO NA VALIDAÇÃO:")
    print(f"   Tipo: {type(e).__name__}")
    print(f"   Mensagem: {e}")
    print(f"\n🔍 Stack Trace Completo:")
    traceback.print_exc()

print("\n" + "="*60)
print("🏁 FIM DO DIAGNÓSTICO")
print("="*60)
```

**Resultado esperado:**
```
✅ Is valid: True
✅ Validação passou! O fix funcionou!
```

### Teste 2: Via Flutter

Após aplicar o fix, abra o app Flutter e tente criar uma denúncia com foto.

**Resultado esperado nos logs:**
```
I/flutter: ✅ 201 /api/denuncias/denuncias/
I/flutter: 📸 URL da foto: https://res.cloudinary.com/dphpzghkh/image/upload/...
```

---

## 🔍 O Que Mudou

| Antes | Depois |
|-------|--------|
| `user = self.context['request'].user` | `request = self.context.get('request')` |
| ❌ Falha se request for None | `user = request.user if request else None` |
| `if user.is_authenticated:` | ✅ Seguro mesmo sem request |
| | `if user and user.is_authenticated:` |

---

## 📊 Por Que Isso Aconteceu?

1. **Django REST Framework** normalmente passa o `request` no `context` do serializer
2. **Em testes** ou **chamadas internas**, o `request` pode ser `None`
3. **O código antigo assumia** que sempre haveria um `request` válido
4. **O fix adiciona verificação** antes de acessar o `request.user`

---

## ⚠️ Rollback (Se Necessário)

Se algo der errado, restaure o backup:

```bash
docker exec -it voz-do-povo-api bash
cp /app/applications/denuncias/serializers.py.backup /app/applications/denuncias/serializers.py
exit
docker restart voz-do-povo-api
```

---

## ✅ Checklist de Validação

- [ ] Backup criado
- [ ] Código modificado (linhas 60-64)
- [ ] Arquivo salvo
- [ ] Container reiniciado
- [ ] Health check passou
- [ ] Teste no Django shell passou
- [ ] Upload de imagem no Flutter funcionou
- [ ] URL do Cloudinary aparece corretamente

---

## 🎯 Resultado Final Esperado

Após o fix, quando criar uma denúncia com foto no Flutter:

```
✅ Status 201 (Created)
📸 foto: https://res.cloudinary.com/dphpzghkh/image/upload/v1/media/denuncias_fotos/compressed_...jpg
```

**Não mais:**
```
❌ Status 500 (Server Error)
```

---

## 📞 Suporte

Se houver algum problema durante a aplicação do fix:

1. **Verifique os logs:**
   ```bash
   docker logs voz-do-povo-api --tail 50
   ```

2. **Verifique o código editado:**
   ```bash
   docker exec voz-do-povo-api sed -n '59,67p' /app/applications/denuncias/serializers.py
   ```

3. **Restaure o backup se necessário**

---

**Data:** 21 de Novembro de 2025  
**Issue:** Erro 500 no upload de imagens do Flutter  
**Fix:** Validação segura de request.user no serializer  
**Impacto:** Crítico - Bloqueia criação de denúncias com foto  
**Prioridade:** 🔴 URGENTE
