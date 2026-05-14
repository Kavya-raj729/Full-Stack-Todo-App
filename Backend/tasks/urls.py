from django.urls import path
from .views import (
    TaskListView,
    TaskCreateView,
    TaskUpdateView,
    TaskDeleteView,
    toggle_task_complete,
    task_list_api,
    create_task_api,
    delete_task_api,
    toggle_task_api
)
urlpatterns = [
    path('', TaskListView.as_view(), name='task-list'),
    path('task-create/', TaskCreateView.as_view(), name='task-create'),
    path('task-update/<int:pk>/', TaskUpdateView.as_view(), name='task-update'),
    path('task-delete/<int:pk>/', TaskDeleteView.as_view(), name='task-delete'),
    path('task-toggle/<int:pk>/', toggle_task_complete, name='task-toggle'),
    path('api/tasks/', task_list_api),
    path('api/tasks/create/', create_task_api),
    path('api/tasks/delete/<int:pk>/', delete_task_api),
    path('api/tasks/toggle/<int:pk>/', toggle_task_api),
]

