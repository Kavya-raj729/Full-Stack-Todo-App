from django.shortcuts import get_object_or_404, redirect
from django.urls import reverse_lazy
from django.views.generic import (
    ListView,
    CreateView,
    UpdateView,
    DeleteView
)

from django.contrib.auth.mixins import LoginRequiredMixin

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import Task
from .serializers import TaskSerializer


# =========================
# API VIEWS
# =========================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def task_list_api(request):

    tasks = Task.objects.filter(user=request.user)

    serializer = TaskSerializer(tasks, many=True)

    return Response(serializer.data)


@api_view(['POST'])
def create_task_api(request):

    print("RAW REQUEST DATA:")
    print(request.data)

    serializer = TaskSerializer(data=request.data)

    print("SERIALIZER OBJECT:")
    print(serializer)

    if serializer.is_valid():

        print("VALIDATED DATA:")
        print(serializer.validated_data)

        serializer.save(user=request.user)

        print("SERIALIZED RESPONSE:")
        print(serializer.data)

        return Response(serializer.data)

    print("ERRORS:")
    print(serializer.errors)

    return Response(serializer.errors, status=400)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_task_api(request, pk):

    task = get_object_or_404(
        Task,
        id=pk,
        user=request.user
    )

    task.delete()

    return Response(
        {
            'message': 'Task Deleted Successfully'
        },
        status=status.HTTP_200_OK
    )


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def toggle_task_api(request, pk):

    task = get_object_or_404(
        Task,
        id=pk,
        user=request.user
    )

    task.completed = not task.completed
    task.save()

    serializer = TaskSerializer(task)

    return Response(
        {
            'message': 'Task Updated Successfully',
            'data': serializer.data
        },
        status=status.HTTP_200_OK
    )


# =========================
# TEMPLATE VIEWS
# =========================

class TaskListView(LoginRequiredMixin, ListView):

    model = Task
    context_object_name = 'tasks'
    template_name = 'tasks/task_list.html'
    login_url = '/'

    ordering = ['completed', '-created_at']

    def get_queryset(self):

        return Task.objects.filter(
            user=self.request.user
        )


class TaskCreateView(LoginRequiredMixin, CreateView):

    model = Task
    fields = ['title', 'description']
    template_name = 'tasks/task_form.html'
    success_url = reverse_lazy('task-list')
    login_url = '/'

    def form_valid(self, form):

        form.instance.user = self.request.user

        return super().form_valid(form)


class TaskUpdateView(LoginRequiredMixin, UpdateView):

    model = Task
    fields = ['title', 'description']
    template_name = 'tasks/task_form.html'
    success_url = reverse_lazy('task-list')
    login_url = '/'

    def get_queryset(self):

        return Task.objects.filter(
            user=self.request.user
        )

    def get_context_data(self, **kwargs):

        context = super().get_context_data(**kwargs)

        context['is_update'] = True

        return context


class TaskDeleteView(LoginRequiredMixin, DeleteView):

    model = Task
    context_object_name = 'task'
    template_name = 'tasks/task_confirm_delete.html'
    success_url = reverse_lazy('task-list')
    login_url = '/'

    def get_queryset(self):

        return Task.objects.filter(
            user=self.request.user
        )


# =========================
# TOGGLE TASK (HTML VIEW)
# =========================

def toggle_task_complete(request, pk):

    task = get_object_or_404(
        Task,
        pk=pk,
        user=request.user
    )

    task.completed = not task.completed
    task.save()

    return redirect('task-list')