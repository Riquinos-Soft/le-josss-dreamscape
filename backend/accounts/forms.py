from django import forms
from django.contrib.auth import password_validation
from .models import Account
from .catalog import OPTIONS, LABELS, SPANISH, DEFAULT


class Credentials(forms.Form):
    email = forms.CharField(label="Usuario o correo", max_length=254, widget=forms.TextInput(attrs={"autocomplete": "username", "autocapitalize": "none"}))
    password = forms.CharField(label="Contraseña", max_length=128, strip=False,
                              widget=forms.PasswordInput(attrs={"autocomplete": "current-password"}))


class Registration(Credentials):
    email = forms.EmailField(label="Correo", max_length=254, widget=forms.EmailInput(attrs={"autocomplete": "email"}))
    password = forms.CharField(label="Contraseña", max_length=128, strip=False,
                              widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}))
    confirmation = forms.CharField(label="Repite la contraseña", max_length=128, strip=False,
                                  widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}))

    def clean(self):
        data = super().clean()
        if data.get("password") != data.get("confirmation"):
            self.add_error("confirmation", "Las contraseñas no coinciden.")
        if data.get("password"):
            password_validation.validate_password(data["password"], Account(email=data.get("email", "")))
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
