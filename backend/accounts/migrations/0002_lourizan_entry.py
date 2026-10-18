from django.db import migrations, models
from django.db.models import F
from django.utils import timezone


def relocate_test_characters(apps, schema_editor):
    Character = apps.get_model("accounts", "Character")
    GameTicket = apps.get_model("accounts", "GameTicket")
    database = schema_editor.connection.alias
    characters = Character.objects.using(database).filter(place="laboratory_v1")
    GameTicket.objects.using(database).filter(character__in=characters).delete()
    characters.update(place="lourizan", position=[9.6, 0.05, 0],
                      generation=F("generation") + 1, revision=F("revision") + 1,
                      active_session="", checkpoint_sequence=0, saved_at=timezone.now())


class Migration(migrations.Migration):
    dependencies = [("accounts", "0001_initial")]
    operations = [
        migrations.AlterField(model_name="character", name="place", field=models.CharField(default="lourizan", max_length=40)),
        migrations.RunPython(relocate_test_characters, migrations.RunPython.noop),
    ]
