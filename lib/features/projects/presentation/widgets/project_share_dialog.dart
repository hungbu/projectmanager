import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/api_service.dart';

class ProjectShareDialog extends StatefulWidget {
  final String projectId;
  final String? existingAccessCode;

  const ProjectShareDialog({
    super.key,
    required this.projectId,
    this.existingAccessCode,
  });

  @override
  State<ProjectShareDialog> createState() => _ProjectShareDialogState();
}

class _ProjectShareDialogState extends State<ProjectShareDialog> {
  bool _isLoading = false;
  String? _accessCode;
  String? _shareUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccessCode != null) {
      _accessCode = widget.existingAccessCode;
      _shareUrl = _generateShareUrl(widget.existingAccessCode!);
    } else {
      _fetchAccessCode();
    }
  }

  String _generateShareUrl(String accessCode) {
    // You can configure this URL based on your deployment
    final frontendUrl = ApiEndpoints.baseUrl
        .replaceAll('/api', '')
        .replaceAll('pm.vnwebsite.net', 'pm.vnwebsite.net');
    return '$frontendUrl/public/project/$accessCode';
  }

  Future<void> _fetchAccessCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endpoint = ApiEndpoints.getAccessCode.replaceAll('{id}', widget.projectId);
      final response = await ApiService.get(endpoint);

      if (response['has_access_code'] == true) {
        setState(() {
          _accessCode = response['access_code'];
          _shareUrl = response['share_url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAccessCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endpoint = ApiEndpoints.generateAccessCode.replaceAll('{id}', widget.projectId);
      final response = await ApiService.post(endpoint, {});

      setState(() {
        _accessCode = response['access_code'];
        _shareUrl = response['share_url'];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share link generated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate share link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _revokeAccessCode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Share Link?'),
        content: const Text(
          'This will invalidate the current share link. Anyone with the link will no longer be able to access this project. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endpoint = ApiEndpoints.revokeAccessCode.replaceAll('{id}', widget.projectId);
      await ApiService.delete(endpoint);

      setState(() {
        _accessCode = null;
        _shareUrl = null;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share link revoked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to revoke share link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_shareUrl == null) return;

    await Clipboard.setData(ClipboardData(text: _shareUrl!));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Link copied to clipboard'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.share, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Share Project'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _accessCode == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_accessCode == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate a share link to allow partners or clients to view this project\'s Kanban board without logging in.',
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The shared view is read-only. No one can edit tasks or project details.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateAccessCode,
              icon: const Icon(Icons.link),
              label: const Text('Generate Share Link'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share this link with your partners or clients:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _shareUrl ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy to clipboard',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anyone with this link can view the project. Keep it secure!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _revokeAccessCode,
                icon: const Icon(Icons.link_off),
                label: const Text('Revoke Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('Copy Link'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

