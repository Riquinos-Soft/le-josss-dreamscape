from django import forms
from django.core.validators import RegexValidator
from django.contrib.auth import password_validation
from .models import Account
from .catalog import OPTIONS, LABELS, SPANISH, DEFAULT


class Credentials(forms.Form):
    email = forms.CharField(label="Usuario o correo", max_length=254, widget=forms.TextInput(attrs={"autocomplete": "username", "autocapitalize": "none"}))
    password = forms.CharField(label="Contraseña", max_length=128, strip=False,
                              widget=forms.PasswordInput(attrs={"autocomplete": "current-password"}))


class Registration(forms.Form):
    username = forms.CharField(label="Usuario", min_length=3, max_length=24,
        validators=[RegexValidator(r"^[a-zA-Z][a-zA-Z0-9_]*$", "Empieza con una letra; usa letras, números o guion bajo.")],
        widget=forms.TextInput(attrs={"autocomplete": "username", "autocapitalize": "none"}))
    password = forms.CharField(label="Contraseña", max_length=128, strip=False,
                              widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}))
    confirmation = forms.CharField(label="Repite la contraseña", max_length=128, strip=False,
                                  widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}))

    def clean_username(self):
        username = self.cleaned_data["username"].lower()
        if username in {"test", "test2", "beta"} or Account.objects.filter(username__iexact=username).exists():
            raise forms.ValidationError("Ese usuario ya está en uso. Elige otro.")
        return username

    def clean(self):
        data = super().clean()
        if data.get("password") != data.get("confirmation"):
            self.add_error("confirmation", "Las contraseñas no coinciden.")
        if data.get("password"):
            password_validation.validate_password(data["password"], Account(username=data.get("username", "")))
        return data


class CharacterForm(forms.Form):
    name = forms.CharField(label="Nombre del personaje", min_length=2, max_length=24)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for key, label in LABELS.items():
            self.fields[key] = forms.ChoiceField(label=label, choices=[(v, SPANISH[v]) for v in OPTIONS[key]])

    def clean_name(self):
        name = " ".join(self.cleaned_data["name"].split())
        if len(name) < 2 or not all(c.isalpha() or c in " '-" for c in name):
            raise forms.ValidationError("Usa entre 2 y 24 letras, espacios, guiones o apóstrofos.")
        return name

    def appearance(self):
        return {**DEFAULT, **{k: self.cleaned_data[k] for k in LABELS}}
