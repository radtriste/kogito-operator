// Copyright 2020 Red Hat, Inc. and/or its affiliates
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package config

type ImageTagsInterface interface {
	GetImageTagPointerFromPersistenceType(imageType ImageType, persistenceType ImagePersistenceType) *string
}

type ImageType string

const (
	DataIndexImageType         ImageType = "data-index"
	ExplainabilityImageType    ImageType = "explainability"
	JobServiceImageType        ImageType = "jobs-service"
	ManagementConsoleImageType ImageType = "mgmt-console"
	TaskConsoleImageType       ImageType = "task-console"
	TrustyImageType            ImageType = "trusty"
	TrustyUIImageType          ImageType = "trusty-ui"
)

type ImagePersistenceType string

const (
	EphemeralPersistenceType  ImagePersistenceType = "ephemeral"
	InfinispanPersistenceType ImagePersistenceType = "infinispan"
	MongoDBPersistenceType    ImagePersistenceType = "mongodb"
	PosgresqlPersistenceType  ImagePersistenceType = "posgresql"
	RedisPersistenceType      ImagePersistenceType = "redis"
)

var (
	imageTypePersistenceMapping map[ImageType][]ImagePersistenceType = map[ImageType][]ImagePersistenceType{
		DataIndexImageType:         {EphemeralPersistenceType, InfinispanPersistenceType, MongoDBPersistenceType, PosgresqlPersistenceType},
		ExplainabilityImageType:    {EphemeralPersistenceType},
		JobServiceImageType:        {EphemeralPersistenceType, InfinispanPersistenceType, MongoDBPersistenceType, PosgresqlPersistenceType},
		ManagementConsoleImageType: {EphemeralPersistenceType},
		TaskConsoleImageType:       {EphemeralPersistenceType},
		TrustyImageType:            {InfinispanPersistenceType, RedisPersistenceType},
		TrustyUIImageType:          {EphemeralPersistenceType},
	}
)

type ImageTags struct {
	tags map[ImageType]map[ImagePersistenceType]*string
}

func (imageTags *ImageTags) GetImageTagPointerFromPersistenceType(imageType ImageType, persistenceType ImagePersistenceType) *string {
	if len(imageTags.tags[imageType]) <= 0 {
		imageTags.tags[imageType] = make(map[ImagePersistenceType]*string)
	}
	if imageTags.tags[imageType][persistenceType] == nil {
		tag := ""
		imageTags.tags[imageType][persistenceType] = &tag
	}

	return imageTags.tags[imageType][persistenceType]
}
