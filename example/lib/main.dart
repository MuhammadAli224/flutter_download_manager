import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DownloadNotificationService.init(
    channelName: 'My App Downloads',
    progressColor: Color(0xFF1565C0),
    ledColor: Color(0xFF1565C0),
  );
  await DownloadNotificationService.requestPermission();

  runApp(const MyApp());
}

const _samples = [
  {
    'label': 'PDF',
    'url':
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  },
  {'label': 'Image', 'url': 'https://www.w3.org/Icons/w3c_home.png'},
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF1565C0),
      useMaterial3: true,
    ),
    home: const DownloadScreen(),
  );
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late final DownloadController controller;

  @override
  void initState() {
    super.initState();

    controller = DownloadController(
      maxConcurrent: 2,
      // ← concurrent limit
      onTaskCompleted: (t) => _snack('✓ ${t.fileName} saved'),
      onTaskFailed: (t) => _snack('✗ ${t.fileName} failed'),
      onTaskPaused: (t) => _snack('⏸ ${t.fileName} paused'),
      onTaskProgress: (_) => setState(() {}), // ← global progress hook
    );

    // Restore tasks from previous session
    controller.restoreTasks().then((_) => setState(() {}));

    // Stream-based updates (alternative to onTaskProgress callback)
    controller.onTaskUpdated.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void refresh() => setState(() {});

  void _addCustomTask() {
    final urlCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final folderCtrl = TextEditingController(text: 'MyApp');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'File name (optional)',
              ),
            ),
            TextField(
              controller: folderCtrl,
              decoration: const InputDecoration(labelText: 'Sub-folder'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = urlCtrl.text.trim();
              if (url.isEmpty) return;
              controller.addTask(
                url,
                fileName: nameCtrl.text.trim().isEmpty
                    ? null
                    : nameCtrl.text.trim(),
                subFolder: folderCtrl.text.trim().isEmpty
                    ? null
                    : folderCtrl.text.trim(),
                headers: {'Accept': '*/*'},
                // ← custom headers
                maxRetries: 3,
                // ← retry policy
                retryDelay: const Duration(seconds: 2),
                priority: 1, // ← priority
              );
              refresh();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager'),
        actions: [
          // Start all
          IconButton(
            tooltip: 'Start all',
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => controller.startAll(onUpdate: refresh),
          ),
          // Pause all
          IconButton(
            tooltip: 'Pause all',
            icon: const Icon(Icons.pause_circle_outline),
            onPressed: () => controller.pauseAll(onUpdate: refresh),
          ),
          // Cancel all
          IconButton(
            tooltip: 'Cancel all',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () => controller.cancelAll(onUpdate: refresh),
          ),
          // Clear finished
          IconButton(
            tooltip: 'Clear finished',
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              controller.tasks.removeWhere(
                (t) =>
                    t.status == DownloadStatus.completed ||
                    t.status == DownloadStatus.error,
              );
              refresh();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Quick-add sample files
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick add', style: theme.textTheme.labelSmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    // Single task
                    ..._samples.map(
                      (f) => ActionChip(
                        avatar: Icon(
                          FileHelper.getFileIcon(f['url']!),
                          size: 16,
                        ),
                        label: Text(f['label']!),
                        onPressed: () {
                          controller.addTask(
                            f['url']!,
                            subFolder: 'MyApp', // ← subfolder
                            maxRetries: 2, // ← retry
                            headers: {'Accept': '*/*'}, // ← headers
                          );
                          refresh();
                        },
                      ),
                    ),
                    // Batch add
                    ActionChip(
                      avatar: const Icon(Icons.playlist_add, size: 16),
                      label: const Text('Batch (both)'),
                      onPressed: () {
                        controller.addBatch(
                          // ← batch
                          _samples.map((f) => f['url']!).toList(),
                          subFolder: 'MyApp/Batch',
                          maxRetries: 1,
                        );
                        refresh();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: controller.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No downloads yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final task = controller.tasks[i];

                      // StreamBuilder alternative (optional — controller already calls setState via onTaskProgress)
                      return StreamBuilder<DownloadTask>(
                        // ← stream-based
                        stream: controller.onTaskUpdated.where(
                          (t) => t.id == task.id,
                        ),
                        initialData: task,
                        builder: (_, snap) {
                          final t = snap.data ?? task;
                          return _TaskCard(
                            task: t,
                            onStart: () => controller.startTask(
                              t,
                              onUpdate: refresh,
                              showNotification: true,
                            ),
                            onPause: () =>
                                controller.pauseTask(t, onUpdate: refresh),
                            onResume: () =>
                                controller.resumeTask(t, onUpdate: refresh),
                            onCancel: () =>
                                controller.cancelTask(t, onUpdate: refresh),
                            onRemove: () {
                              controller.removeTask(t, onUpdate: refresh);
                              refresh();
                            },
                            onRetry: () =>
                                controller.startTask(t, onUpdate: refresh),
                            onOpen: () => controller.startTask(
                              t,
                              onUpdate: refresh,
                              openAfterDownload: true,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomTask,
        icon: const Icon(Icons.add_link),
        label: const Text('Add URL'),
      ),
    );
  }
}

// ── Task Card (unchanged from before) ────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRemove,
    required this.onRetry,
    required this.onOpen,
  });

  final DownloadTask task;
  final VoidCallback onStart,
      onPause,
      onResume,
      onCancel,
      onRemove,
      onRetry,
      onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = task.status;

    final (Color color, IconData icon) = switch (status) {
      DownloadStatus.idle => (theme.colorScheme.outline, Icons.schedule),
      DownloadStatus.downloading => (
        theme.colorScheme.primary,
        Icons.downloading,
      ),
      DownloadStatus.paused => (Colors.orange, Icons.pause_circle),
      DownloadStatus.completed => (Colors.green, Icons.check_circle),
      DownloadStatus.error => (theme.colorScheme.error, Icons.error),
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    FileHelper.getFileIcon(task.fileName),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(icon, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            _label(status),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                            ),
                          ),

                          if (task.retryCount > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              'retry ${task.retryCount}/${task.maxRetries}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                          if (task.subFolder != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.folder_outlined,
                              size: 11,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                task.subFolder!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (status == DownloadStatus.downloading &&
                          task.speed > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          FileHelper.formatSpeed(task.speed),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _actions(theme, status),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(task.progress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  FileHelper.getFileType(task.fileName),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(ThemeData theme, DownloadStatus status) => switch (status) {
    DownloadStatus.idle => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Start',
          icon: const Icon(Icons.play_arrow_rounded),
          onPressed: onStart,
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ],
    ),
    DownloadStatus.downloading => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Pause',
          icon: const Icon(Icons.pause_rounded),
          onPressed: onPause,
        ),
        IconButton(
          tooltip: 'Cancel',
          icon: const Icon(Icons.stop_rounded),
          color: theme.colorScheme.error,
          onPressed: onCancel,
        ),
      ],
    ),
    DownloadStatus.paused => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Resume',
          icon: const Icon(Icons.play_arrow_rounded),
          color: Colors.orange,
          onPressed: onResume,
        ),
        IconButton(
          tooltip: 'Cancel',
          icon: const Icon(Icons.stop_rounded),
          color: theme.colorScheme.error,
          onPressed: onCancel,
        ),
      ],
    ),
    DownloadStatus.completed => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Open',
          icon: const Icon(Icons.open_in_new_rounded),
          color: Colors.green,
          onPressed: onOpen,
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ],
    ),
    DownloadStatus.error => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Retry',
          icon: const Icon(Icons.refresh_rounded),
          color: theme.colorScheme.error,
          onPressed: onRetry,
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ],
    ),
  };

  String _label(DownloadStatus s) => switch (s) {
    DownloadStatus.idle => 'Ready',
    DownloadStatus.downloading => 'Downloading',
    DownloadStatus.paused => 'Paused',
    DownloadStatus.completed => 'Completed',
    DownloadStatus.error => 'Failed',
  };
}
