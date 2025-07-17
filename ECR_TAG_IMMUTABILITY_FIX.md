# ECR Tag Immutability Fix

## Problem

The error `tag invalid: The image tag 'latest' already exists in the repository and cannot be overwritten because the tag is immutable` occurs when:

1. ECR repository is configured with `imageTagMutability: IMMUTABLE`
2. Attempting to push the same tag (`latest`) multiple times
3. Each push tries to overwrite the existing tag, which is forbidden

## Solution Implemented

### 1. Unique Tag Strategy

Instead of using `latest`, we now generate unique tags using:

```
{environment}-{timestamp}-{commit-sha}
```

Example: `development-20250717-143052-a1b2c3d4`

### 2. Dual Tagging Approach

- **Primary**: Unique tag (guaranteed to work with immutable repos)
- **Fallback**: Still attempt `latest` for compatibility, but don't fail if it exists

### 3. Enhanced Image Management

- Keep the 5 most recent images per environment
- Clean up older images to prevent repository bloat
- Better tracking of image versions

## Code Changes

### Build and Push Step

```yaml
- name: Build, tag, and push image to Amazon ECR
  run: |
    # Create unique tag
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    COMMIT_SHA=$(echo ${{ github.sha }} | cut -c1-8)
    UNIQUE_TAG="${ENV_NAME}-${TIMESTAMP}-${COMMIT_SHA}"

    # Build with unique tag
    docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$UNIQUE_TAG .

    # Push unique tag (always works)
    docker push $ECR_REGISTRY/$ECR_REPOSITORY:$UNIQUE_TAG

    # Try to push latest (optional)
    docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest || echo "Latest tag exists"
```

### Cleanup Strategy

```yaml
- name: Clean up old ECR images (keep latest 5 per environment)
  run: |
    # Get all image tags for this environment
    ENV_TAGS=$(aws ecr list-images \
      --repository-name $ECR_REPOSITORY \
      --query "imageIds[?starts_with(imageTag, '$ENV_NAME-')].imageTag" \
      --output text)

    # Count images and keep only the 5 newest
    # Sort by timestamp embedded in tag name
    # Delete older images to manage storage costs
```

## Recent Fixes

### ECR Cleanup Query Error

**Issue**: JMESPath query failing with null `imageLastPushedAt` values

```
In function sort_by(), invalid type for value: ..., expected one of: ['string', 'number'], received: "null"
```

**Solution**: Replaced complex JMESPath sorting with simpler tag-based approach:

- Use `list-images` instead of `describe-images`
- Filter by tag prefix matching environment
- Sort tags by embedded timestamp (YYYYMMDD-HHMMSS format)
- More reliable and handles null values gracefully

## Benefits

### Reliability

- ✅ **No more tag conflicts**: Unique tags prevent immutability errors
- ✅ **Backwards compatibility**: Still supports `latest` when possible
- ✅ **Environment isolation**: Each environment has its own tag pattern

### Traceability

- ✅ **Deployment tracking**: Timestamp and commit SHA in tag
- ✅ **Easy rollback**: Can identify exact version deployed
- ✅ **Environment clarity**: Tag includes environment name

### Cost Management

- ✅ **Storage optimization**: Cleanup old images automatically
- ✅ **Retention policy**: Keep reasonable number of versions
- ✅ **Per-environment cleanup**: Don't affect other environments

## Usage

The workflow now automatically:

1. **Generates unique tags** for each deployment
2. **Pushes both unique and latest tags** (when possible)
3. **Uses the unique tag** in ECS task definitions
4. **Cleans up old images** to manage storage
5. **Provides detailed logging** for troubleshooting

## Example Deployment Flow

```
1. Generate unique tag: development-20250717-143052-a1b2c3d4
2. Build image with unique tag
3. Push unique tag to ECR (✅ always succeeds)
4. Try to push latest tag (may fail, but that's OK)
5. Update ECS task definition with unique tag
6. Deploy to ECS
7. Clean up old images (keep 5 most recent)
```

## Repository Configuration

### For Immutable Repositories

- ✅ **Fully compatible**: Uses unique tags that never conflict
- ✅ **No configuration changes needed**: Works with existing setup

### For Mutable Repositories

- ✅ **Enhanced functionality**: Benefits from unique tags + latest
- ✅ **Better versioning**: Still get the traceability benefits

## Troubleshooting

### If you still see tag conflicts:

1. Check the repository immutability setting:

   ```bash
   aws ecr describe-repositories --repository-names your-repo-name
   ```

2. Verify the unique tag generation in workflow logs

3. Ensure cleanup process is running successfully

### To change repository mutability (if needed):

```bash
# Make repository mutable (allows overwriting tags)
aws ecr put-image-tag-mutability \
  --repository-name your-repo-name \
  --image-tag-mutability MUTABLE

# Make repository immutable (prevents overwriting tags)
aws ecr put-image-tag-mutability \
  --repository-name your-repo-name \
  --image-tag-mutability IMMUTABLE
```

This solution ensures reliable deployments regardless of ECR repository configuration while providing better version tracking and cost management.
