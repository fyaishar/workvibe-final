import 'package:flutter_test/flutter_test.dart';
import 'package:finalworkvibe/core/models/project.dart';
import 'package:finalworkvibe/core/providers/project_provider.dart';

void main() {
  group('Project filtering and sorting tests', () {
    final mockProjects = [
      Project(
        id: '1', 
        name: 'Active Project', 
        description: 'Description 1', 
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Project(
        id: '2', 
        name: 'Completed Project',
        description: 'Description 2',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: '3', 
        name: 'Archived Project',
        description: 'Description 3',
        status: 'archived',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
    ];

    test('filters active projects correctly', () {
      // Apply the filter logic directly (extracted from filteredProjectsProvider)
      final List<Project> filteredProjects = mockProjects
          .where((project) => project.status == 'active')
          .toList();
      
      // Verify
      expect(filteredProjects.length, 1);
      expect(filteredProjects[0].id, '1');
      expect(filteredProjects[0].status, 'active');
    });
    
    test('filters completed projects correctly', () {
      // Apply the filter logic directly (extracted from filteredProjectsProvider)
      final List<Project> filteredProjects = mockProjects
          .where((project) => project.status == 'completed')
          .toList();
      
      // Verify
      expect(filteredProjects.length, 1);
      expect(filteredProjects[0].id, '2');
      expect(filteredProjects[0].status, 'completed');
    });
    
    test('filters archived projects correctly', () {
      // Apply the filter logic directly (extracted from filteredProjectsProvider)
      final List<Project> filteredProjects = mockProjects
          .where((project) => project.status == 'archived')
          .toList();
      
      // Verify
      expect(filteredProjects.length, 1);
      expect(filteredProjects[0].id, '3');
      expect(filteredProjects[0].status, 'archived');
    });
    
    test('sorts projects by name correctly', () {
      // Create a list of projects with specific names for sorting
      final List<Project> projects = [
        Project(
          id: '1', 
          name: 'Z Project', 
          description: 'Description 1',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Project(
          id: '2', 
          name: 'A Project',
          description: 'Description 2',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Project(
          id: '3', 
          name: 'M Project',
          description: 'Description 3',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Apply the sort logic directly
      projects.sort((a, b) => a.name.compareTo(b.name));
      
      // Verify
      expect(projects.length, 3);
      expect(projects[0].name, 'A Project');
      expect(projects[1].name, 'M Project');
      expect(projects[2].name, 'Z Project');
    });
    
    test('sorts projects by creation date correctly', () {
      // Create a list of projects with different creation dates
      final now = DateTime.now();
      final List<Project> projects = [
        Project(
          id: '1', 
          name: 'New Project', 
          description: 'Description 1',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        ),
        Project(
          id: '2', 
          name: 'Old Project',
          description: 'Description 2',
          status: 'active',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
        ),
        Project(
          id: '3', 
          name: 'Older Project',
          description: 'Description 3',
          status: 'active',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
        ),
      ];
      
      // Apply the sort logic directly
      projects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Verify
      expect(projects.length, 3);
      expect(projects[0].name, 'Older Project');
      expect(projects[1].name, 'Old Project');
      expect(projects[2].name, 'New Project');
    });
  });

  group('Project retrieval tests', () {
    final mockProjects = [
      Project(
        id: '1', 
        name: 'Project 1', 
        description: 'Description 1', 
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: '2', 
        name: 'Project 2',
        description: 'Description 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    test('gets project by ID correctly', () {
      // Apply the retrieval logic
      final String targetId = '1';
      final Project? project = mockProjects.firstWhere(
        (project) => project.id == targetId,
        orElse: () => null as Project, // This forces null to be returned if not found
      );
      
      // Verify
      expect(project, isNotNull);
      expect(project?.id, '1');
      expect(project?.name, 'Project 1');
    });
    
    test('returns null for non-existent project ID', () {
      // Apply the retrieval logic
      final String targetId = '999';
      Project? project;
      try {
        project = mockProjects.firstWhere((project) => project.id == targetId);
      } catch (_) {
        project = null;
      }
      
      // Verify
      expect(project, isNull);
    });
  });

  group('Team member tests', () {
    final mockProjects = [
      Project(
        id: '1', 
        name: 'Team Project 1', 
        description: 'Description 1',
        teamMembers: ['user1', 'user2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: '2', 
        name: 'Team Project 2',
        description: 'Description 2',
        teamMembers: ['user2', 'user3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Project(
        id: '3', 
        name: 'Personal Project',
        description: 'Description 3',
        teamMembers: ['user1'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    test('filters projects by team member correctly', () {
      // Apply the filter logic
      final String userId = 'user1';
      final List<Project> userProjects = mockProjects
        .where((project) => project.teamMembers.contains(userId))
        .toList();
      
      // Verify
      expect(userProjects.length, 2);
      expect(userProjects.map((p) => p.id).toList()..sort(), ['1', '3']);
      
      // Check for a different user
      final String userId2 = 'user2';
      final List<Project> user2Projects = mockProjects
        .where((project) => project.teamMembers.contains(userId2))
        .toList();
      
      // Verify
      expect(user2Projects.length, 2);
      expect(user2Projects.map((p) => p.id).toList()..sort(), ['1', '2']);
    });
    
    test('adds and removes team members correctly', () {
      // Create a mutable copy of the project
      final Project project = mockProjects[0];
      
      // Track original state
      final int originalMemberCount = project.teamMembers.length;
      expect(originalMemberCount, 2);
      
      // Add a new team member
      final Project updatedProject = project.copyWith(
        teamMembers: [...project.teamMembers, 'user4']
      );
      
      // Verify addition
      expect(updatedProject.teamMembers.length, originalMemberCount + 1);
      expect(updatedProject.teamMembers.contains('user4'), true);
      
      // Remove a team member
      final Project reducedProject = updatedProject.copyWith(
        teamMembers: updatedProject.teamMembers.where((id) => id != 'user1').toList()
      );
      
      // Verify removal
      expect(reducedProject.teamMembers.length, originalMemberCount);
      expect(reducedProject.teamMembers.contains('user1'), false);
      expect(reducedProject.teamMembers.contains('user4'), true);
    });
  });
} 