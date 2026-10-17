from django.conf import settings
from django.contrib.auth.views import PasswordResetConfirmView, PasswordResetCompleteView
from django.urls import path, re_path
from django.views.static import serve
from accounts import views, authority

urlpatterns = [
    path("", views.entry, name="entry"), path("register/", views.register, name="register"),
    path("verify/<str:token>/", views.verify), path("recover/", views.recover, name="recover"),
    path("reset/<uidb64>/<token>/", PasswordResetConfirmView.as_view(template_name="accounts/reset.html", success_url="/reset/done/")),
    path("reset/done/", PasswordResetCompleteView.as_view(template_name="accounts/reset_done.html")),
    path("character/create/", views.create, name="create"), path("play/", views.play, name="play"),
    path("character/edit/", views.edit, name="edit"),
    path("logout/", views.sign_out, name="logout"), path("api/ticket/", views.ticket),
    path("internal/start/", authority.start), path("internal/heartbeat/", authority.heartbeat),
    path("internal/consume/", authority.consume), path("internal/checkpoint/", authority.checkpoint),
]
if settings.DEBUG:
    urlpatterns += [re_path(r"^game/(?P<path>.*)$", serve, {"document_root": settings.GAME_EXPORT_DIR}),
                    re_path(r"^parts/(?P<path>.*)$", serve, {"document_root": settings.BASE_DIR.parent / "game/v2/characters/parts"})]
